begin
  require 'memcached'
rescue LoadError => error
  raise "Please install the memcached gem to use the memcached transport."
end

module ElasticSearch
  module Transport
    class Memcached < Base
      Response = Struct.new(:status, :headers, :body)

      DEFAULTS = {
        :timeout => 5
      }.freeze

      def initialize(server, options={})
        super
        @options = DEFAULTS.merge(@options)
      end

      def connect!
        @memcached = ::Memcached.new(@server, :timeout => @options[:timeout]) #TODO allow passing other options?
      end

      def close
        @memcached.quit
      end

      def all_nodes
        memcached_addresses = nodes_info([])["nodes"].collect { |id, node| node["memcached_address"] }
        memcached_addresses.collect! do |a|
          if a =~ /inet\[.*\/([\d.:]+)\]/
            $1
          end
        end.compact!
        memcached_addresses
      end

      private

      def request(method, operation, params={}, body=nil, headers={})
        begin
          uri = generate_uri(operation)
          query = generate_query_string(params)
          path = [uri, query].join("?")
          #puts "request: #{method} #{@server} #{path} #{body}"
          response = case method
          when :get
            @memcached.get(path, false)
          when :put, :post
            #TODO put vs post?
            @memcached.set(path, body, 0, false)
          when :delete
            @memcached.delete(path)
          end
          #puts "response: #{response}"
          response = Response.new(200, {}, response) #TODO
          handle_error(response) if response.status >= 500
          response
        rescue Exception => e
          case e
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
