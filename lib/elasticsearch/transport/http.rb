require 'patron'
require 'cgi'

module ElasticSearch
  module Transport
    class HTTP < Base

      DEFAULTS = {
        :timeout => 5
      }.freeze

      def initialize(server, options={})
        super
        @options = DEFAULTS.merge(@options)

        # Make sure the server starts with a URI scheme.
        unless @server =~ /^(([^:\/?#]+):)?\/\//
          @server = 'http://' + @server
        end
      end

      def connect!
        @session = Patron::Session.new
        @session.base_url = @server
        @session.timeout = @options[:timeout]
        @session.headers['User-Agent'] = 'ElasticSearch.rb v0.1'
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
          uri = generate_uri(operation)
          query = generate_query_string(params)
          path = [uri, query].join("?")
          #puts "request: #{method} #{@server} #{path} #{body}"
          response = @session.request(method, path, headers, :data => body)
          handle_error(response) if response.status >= 500
          response
        rescue Exception => e
          case e
          when Patron::ConnectionFailed
            raise ConnectionFailed
          when Patron::HostResolutionError
            raise HostResolutionError
          when Patron::TimeoutError
            raise TimeoutError
          else
            raise e
          end
        end
      end
    end
  end
end
