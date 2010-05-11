require 'patron'

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
        response = request(:get, generate_path(:index => index, :type => type, :id => id))
        response.status == 404 ? nil : encoder.decode(response.body)
        #TODO return structure
      end

      def search(index, type, query, options={})
        if query.is_a?(Hash)
          # patron cannot submit get requests with content, so if query is a hash, post it instead (assume a query hash is using the query dsl)
          response = request(:post, generate_path(:index => index, :type => type, :id => "_search", :params => options), encoder.encode(:query => query))
        else
          response = request(:get, generate_path(:index => index, :type => type, :id => "_search", :params => options.merge(:q => query)))
        end
        encoder.decode(response.body)
        #TODO return structure
      end

      def delete(index, type, id, options={})
        request(:delete, generate_path(:index => index, :type => type, :id => id))
        #TODO return value
      end

      private

      # :index - one or many index names
      # :type - one or many types
      # :id - one id
      # :params - hash of query params
      def generate_path(options)
        path = ""
        path << "/#{Array(options[:index]).collect { |i| escape(i) }.join(",")}" if options[:index]
        path << "/#{Array(options[:type]).collect { |t| escape(t) }.join(",")}" if options[:type]
        path << "/#{escape(options[:id])}" if options[:id]
        path << "?" << query_string(options[:params]) if options[:params] && !options[:params].empty?
        path
      end

      # faster than CGI.escape
      # stolen from RSolr, which stole it from Rack
      def escape(string)
        string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
          #'%'+$1.unpack('H2'*$1.size).join('%').upcase
          '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
        }.tr(' ', '+')
      end

      # encodes the string as utf-8 in Ruby 1.9
      # returns the unaltered string in Ruby 1.8
      def encode_utf8(string)
        (string.respond_to?(:force_encoding) and string.respond_to?(:encoding)) ?
          string.force_encoding(Encoding::UTF_8) : string
      end

      # Return the bytesize of String; uses String#size under Ruby 1.8 and
      # String#bytesize under 1.9.
      if ''.respond_to?(:bytesize)
        def bytesize(string)
          string.bytesize
        end
      else
        def bytesize(string)
          string.size
        end
      end

      #doesn't handle arrays or hashes or what have you
      def query_string(params)
        params.collect { |k,v| "#{escape(k.to_s)}=#{escape(v.to_s)}" }.join("&")
      end

      def request(method, path, body=nil, headers={})
        begin
          puts "request: #{@session.base_url}#{path} body:#{body}"
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
