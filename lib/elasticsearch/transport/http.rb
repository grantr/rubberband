require 'patron'
require 'cgi'

module ElasticSearch
  class ConnectionFailed < RetryableError; end
  class HostResolutionError < RetryableError; end
  class TimeoutError < RetryableError; end
  class RequestError < FatalError; end

  module Transport
    class HTTP < Base

      DEFAULTS = {
        :timeout => 5
      }.freeze

      def initialize(server, options={})
        super
        @options = DEFAULTS.merge(@options)
      end

      def connect!
        @session = Patron::Session.new
        @session.base_url = @server
        @session.timeout = @options[:timeout]
        @session.headers['User-Agent'] = 'ElasticSearch.rb v0.1'
        request(:get, "/") # try a get to see if the server responds
      end

      private

      def request(method, operation, params={}, body=nil, headers={})
        begin
          uri = generate_uri(operation)
          query = generate_query_string(params)
          path = [uri, query].join("?")
          #puts "request: #{@server} #{path} #{body}"
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
