require 'patron'
require 'cgi'

module ElasticSearch
  module Transport
    class HTTP < Base
      class ConnectionFailed < RetryableError; end
      class HostResolutionError < RetryableError; end
      class TimeoutError < RetryableError; end

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
        request(:get, "/")
      end

      def index(index, type, id, document, options={})
        body = encoder.is_encoded?(document) ? document : encoder.encode(document)
        request(:put, generate_path(:index => index, :type => type, :id => id), body)
        #TODO return value
      end

      def get(index, type, id, options={})
        encoder.decode(request(:get, generate_path(:index => index, :type => type, :id => id)).body)
      end

      def search(options)
        raise "not implemented"
      end

      def delete(options)
        raise "not implemented"
      end

      private

      def generate_path(options)
        path = ""
        path << "/#{Array(options[:index]).collect { |i| CGI.escape(i) }.join(",")}" if options[:index]
        path << "/#{Array(options[:type]).collect { |t| CGI.escape(t) }.join(",")}" if options[:type]
        path << "/#{CGI.escape(options[:id])}" if options[:id]
        path
      end

      def request(method, path, body=nil, headers={})
        #TODO params and cgi escape params
        begin
          puts "request: #{@session.base_url}"
          @session.request(method, path, headers, :data => body)
        rescue Exception => e
          case e
          when Patron::ConnectionFailed
            raise ConnectionFailed
          when Patron::HostResolutionError
            raise HostResolutionError
          when TimeoutError
            raise TimeoutError
          else
            raise e
          end
        end
      end
    end
  end
end
