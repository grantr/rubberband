begin
  require 'thrift'
rescue LoadError => error
  raise "Please install the thrift gem (>= 0.5.0) to use the Thrift transport."
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "thrift"))
require 'rest'

module ElasticSearch
  module Transport
    class Thrift < Base

      DEFAULTS = {
        :timeout => 5,
        :thrift_protocol => ::Thrift::BinaryProtocol,
        :thrift_protocol_extra_params => [],
        :thrift_transport => ::Thrift::Socket,
        :thrift_transport_wrapper => ::Thrift::BufferedTransport,
        :client_class => ElasticSearch::Thrift::Rest::Client
      }.freeze

      def initialize(server, options={})
        super
        @options = DEFAULTS.merge(@options)
      end

      def connect!
        host, port = parse_server(@server)

        @transport = @options[:thrift_transport].new(host, port.to_i, @options[:timeout])
        @transport = @transport_wrapper.new(@transport) if @transport_wrapper
        @transport.open

        @client = @options[:client_class].new(@options[:thrift_protocol].new(@transport, *@options[:thrift_protocol_extra_params]))
      rescue ::Thrift::TransportException, Errno::ECONNREFUSED
        close
        raise ConnectionFailed
      end

      def close
        @transport.close rescue nil
      end

      def all_nodes
        thrift_addresses = nodes_info([])["nodes"].collect { |id, node| node["thrift_address"] }
        thrift_addresses.collect! do |a|
          if a =~ /.*\/([\d.:]+)/
            $1
          end
        end.compact!
        thrift_addresses
      end

      private

      def parse_server(server)
        host, port = server.to_s.split(":")
        raise ArgumentError, 'Servers must be in the form "host:port"' unless host and port
        [host, port]
      end

      def stringify!(hash)
        hash.keys.each do |k|
          hash[k.to_s] = hash.delete(k).to_s
        end
        hash
      end

      def request(method, operation, params={}, body=nil, headers={})
        begin
          uri = generate_uri(operation)
          #puts "request: #{@server} #{method} #{uri} #{params.inspect} #{body}"
          request = ElasticSearch::Thrift::RestRequest.new
          case method
          when :get
            request.method = ElasticSearch::Thrift::Method::GET
          when :put
            request.method = ElasticSearch::Thrift::Method::PUT
          when :post
            request.method = ElasticSearch::Thrift::Method::POST
          when :delete
            request.method = ElasticSearch::Thrift::Method::DELETE
          end

          request.uri = uri
          request.parameters = stringify!(params)
          request.body = body
          request.headers = stringify!(headers)
          response = @client.execute(request)
          handle_error(response) if response.status >= 500
          response
        rescue Exception => e
          case e
          when ::Thrift::TransportException
            case e.type
            when ::Thrift::TransportException::TIMED_OUT
              raise TimeoutError, $!
            else
              raise ConnectionFailed, $!
            end
          #TODO Thrift::ApplicationException, Thrift::ProtocolException, IOError.. retryable or fatal?
          else
            raise e
          end
        end
      end

    end
  end
end
