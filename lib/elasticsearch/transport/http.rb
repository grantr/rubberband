require 'faraday'

module ElasticSearch
  module Transport
    class HTTP < Base

      DEFAULTS = {
        :timeout => 5,
        :protocol => 'http'
      }.freeze

      attr_accessor :session

      def initialize(server, options={}, &block)
        super
        @options = DEFAULTS.merge(@options)
        @connect_block = block if block_given?

        # Make sure the server starts with a URI scheme.
        unless @server =~ /^(([^:\/?#]+):)?\/\//
          @server = "#{@options[:protocol]}://" + @server
        end
      end

      def connect!
        if @connect_block
          @session = Faraday.new :url => @server, &@connect_block
        else
          @session = Faraday.new :url => @server
        end
        @session.options[:timeout] = @options[:timeout]
      end

      def all_nodes
        http_addresses = nodes_info([])["nodes"].collect { |id, node| node["http_address"] }
        http_addresses.collect! do |a|
          if a =~ /inet\[.*\/([\d.:]+)\]/
            $1
          end
        end.compact!
        http_addresses
      end

      private

      def request(method, operation, params={}, body=nil)
        begin
          response = @session.send(method, generate_uri(operation)) do |req|
            req.params = params
            req.body = body
          end
          # handle all 500 statuses here, other statuses are protocol-specific
          handle_error(response) if response.status >= 500
          response
        rescue Exception => e
          case e
          when Faraday::Error::ConnectionFailed, Errno::EHOSTUNREACH
            raise ConnectionFailed, $!
          when Faraday::Error::TimeoutError
            raise TimeoutError, $!
          else
            raise e
          end
        end
      end
    end
  end
end
