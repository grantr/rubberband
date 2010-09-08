require 'patron'
require 'cgi'

module ElasticSearch
  module Transport
    class HTTP < Base

      class ConnectionFailed < RetryableError; end
      class HostResolutionError < RetryableError; end
      class TimeoutError < RetryableError; end
      class RequestError < FatalError; end

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

      # index api (TODO modulize)

      def index(index, type, id, document, options={})
        body = encoder.is_encoded?(document) ? document : encoder.encode(document)
        if id.nil?
          response = request(:post, generate_path(:index => index, :type => type), body)
        else
          response = request(:put, generate_path(:index => index, :type => type, :id => id), body)
        end
        handle_error(response) unless response.status == 200
        encoder.decode(response.body)
      end

      def get(index, type, id, options={})
        response = request(:get, generate_path(:index => index, :type => type, :id => id))
        return nil if response.status == 404

        handle_error(response) unless response.status == 200
        hit = encoder.decode(response.body)
        unescape_id!(hit) #TODO extract these two calls from here and search
        set_encoding!(hit)
        hit # { "_id", "_index", "_type", "_source" }
      end

      def delete(index, type, id, options={})
        response = request(:delete, generate_path(:index => index, :type => type, :id => id))
        handle_error(response) unless response.status == 200 # ElasticSearch always returns 200 on delete, even if the object doesn't exist
        encoder.decode(response.body)
      end

      def search(index, type, query, options={})
        if query.is_a?(Hash)
          # patron cannot submit get requests with content, so if query is a hash, post it instead (assume a query hash is using the query dsl)
          response = request(:post, generate_path(:index => index, :type => type, :op => "_search", :params => options), encoder.encode(query))
        else
          response = request(:get, generate_path(:index => index, :type => type, :op => "_search", :params => options.merge(:q => query)))
        end
        handle_error(response) unless response.status == 200
        results = encoder.decode(response.body)
        # unescape ids
        results["hits"]["hits"].each do |hit|
          unescape_id!(hit)
          set_encoding!(hit)
        end
        results # {"hits"=>{"hits"=>[{"_id", "_type", "_source", "_index"}], "total"}, "_shards"=>{"failed", "total", "successful"}}
      end

      def count(index, type, query, options={})
        if query.is_a?(Hash)
          # patron cannot submit get requests with content, so if query is a hash, post it instead (assume a query hash is using the query dsl)
          response = request(:post, generate_path(:index => index, :type => type, :op => "_count", :params => options), encoder.encode(query))
        else
          response = request(:get, generate_path(:index => index, :type => type, :op => "_count", :params => options.merge(:q => query)))
        end
        handle_error(response) unless response.status == 200
        encoder.decode(response.body) # {"count", "_shards"=>{"failed", "total", "successful"}}
      end

      # admin index api (TODO modulize)
      #
      def index_status(index_list, options={})
        standard_request(:get, generate_path(:index => index_list, :op => "_status"))
      end

      def create_index(index, create_options={}, options={})
        standard_request(:put, generate_path(:index => index), encoder.encode(create_options))
      end

      def delete_index(index, options={})
        standard_request(:delete, generate_path(:index => index))
      end

      def alias_index(operations, options={})
        standard_request(:post, generate_path(:op => "_aliases"), encoder.encode(operations))
      end

      def update_mapping(index, type, mapping, options)
        standard_request(:put, generate_path(:index => index, :type => type, :op => "_mapping", :params => options), encoder.encode(mapping))
      end

      def flush(index_list, options={})
        standard_request(:post, generate_path(:index => index_list, :op => "_flush", :params => options), "")
      end
      
      def refresh(index_list, options={})
        standard_request(:post, generate_path(:index => index_list, :op => "_refresh"), "")
      end
      
      def snapshot(index_list, options={})
        standard_request(:post, generate_path(:index => index_list, :type => "_gateway", :op => "snapshot"), "")
      end
      
      def optimize(index_list, options={})
        standard_request(:post, generate_path(:index => index_list, :op => "_optimize", :params => options), "")
      end

      # admin cluster api (TODO modulize)
      
      def cluster_health(index_list, options={})
        standard_request(:get, generate_path(:index => "_cluster", :type => "health", :id => index_list, :params => options))
      end

      def cluster_state(options={})
        standard_request(:get, generate_path(:index => "_cluster", :op => "state"))
      end

      def nodes_info(node_list, options={})
        standard_request(:get, generate_path(:index => "_cluster", :type => "nodes", :id => node_list))
      end

      def nodes_stats(node_list, options={})
        standard_request(:get, generate_path(:index => "_cluster", :type => "nodes", :id => node_list, :op => "stats"))
      end

      def shutdown_nodes(node_list, options={})
        standard_request(:post, generate_path(:index => "_cluster", :type => "nodes", :id => node_list, :op => "_shutdown", :params => options), "")
      end

      def restart_nodes(node_list, options={})
        standard_request(:post, generate_path(:index => "_cluster", :type => "nodes", :id => node_list, :op =>  "_restart", :params => options), "")
      end

      # misc helper methods (TODO modulize)
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

      def standard_request(*args)
        response = request(*args)
        handle_error(response) unless response.status == 200
        encoder.decode(response.body)
      end

      # :index - one or many index names
      # :type - one or many types
      # :id - one id
      # :params - hash of query params
      def generate_path(options)
        path = ""
        path << "/#{Array(options[:index]).collect { |i| escape(i.downcase) }.join(",")}" if options[:index] && !options[:index].empty?
        path << "/#{Array(options[:type]).collect { |t| escape(t) }.join(",")}" if options[:type] && !options[:type].empty?
        path << "/#{Array(options[:id]).collect { |id| escape(id) }.join(",")}" if options[:id] && !options[:id].empty?
        path << "/#{options[:op]}" if options[:op]
        path << "?" << query_string(options[:params]) if options[:params] && !options[:params].empty?
        path
      end

      def unescape_id!(hit)
        hit["_id"] = unescape(hit["_id"])
        nil
      end

      def set_encoding!(hit)
        encode_utf8(hit["_source"])
        nil
      end

      # faster than CGI.escape
      # stolen from RSolr, which stole it from Rack
      def escape(string)
        string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
          #'%'+$1.unpack('H2'*$1.size).join('%').upcase
          '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
        }.tr(' ', '+')
      end

      def unescape(string)
        CGI.unescape(string)
      end

      if ''.respond_to?(:force_encoding) && ''.respond_to?(:encoding)
        # encodes the string as utf-8 in Ruby 1.9
        def encode_utf8(string)
          # ElasticSearch only ever returns json in UTF-8 (per the JSON spec) so we can use force_encoding here (#TODO what about ids? can we assume those are always ascii?)
          string.force_encoding(Encoding::UTF_8)
        end
      else
        # returns the unaltered string in Ruby 1.8
        def encode_utf8(string)
          string
        end
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
          #puts "request: #{@session.base_url}#{path} body:#{body}"
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

      def handle_error(response)
        raise RequestError, "(#{response.status}) #{response.body}"
      end
    end
  end
end
