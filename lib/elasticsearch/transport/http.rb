require 'faraday'

module ElasticSearch
  module Transport
    class HTTP < Base

      DEFAULTS = {
        :timeout => 5,
        :protocol => 'http'
      }.freeze

      def initialize(server, options={})
        super
        @options = DEFAULTS.merge(@options)

        # Make sure the server starts with a URI scheme.
        unless @server =~ /^(([^:\/?#]+):)?\/\//
          @server = "#{@options[:protocol]}://" + @server
        end
      end

      def connect!
        @session = Faraday.new :url => @server, :headers => {'User-Agent' => 'ElasticSearch.rb v0.1'}
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

      def request(method, operation, params={}, body=nil, headers={})
        begin
          response = @session.send(method, generate_uri(operation)) do |req|
            req.headers = headers
            req.params = params
            req.body = body
          end
          # handle all 500 statuses here, other statuses are protocol-specific
          handle_error(response) if response.status >= 500
          response
        rescue Exception => e
          case e
          when Faraday::Error::ConnectionFailed
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
