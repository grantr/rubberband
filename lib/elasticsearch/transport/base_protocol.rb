module ElasticSearch
  module Transport
    module IndexProtocol
      def index(index, type, id, document, options={})
        body = encoder.is_encoded?(document) ? document : encoder.encode(document)
        if id.nil?
          response = request(:post, {:index => index, :type => type}, options, body)
        else
          response = request(:put, {:index => index, :type => type, :id => id}, options, body)
        end
        handle_error(response) unless (response.status == 200 or response.status == 201)
        encoder.decode(response.body)
      end

      def get(index, type, id, options={})
        response = request(:get, {:index => index, :type => type, :id => id}, options)
        return nil if response.status == 404

        handle_error(response) unless response.status == 200
        hit = encoder.decode(response.body)
        unescape_id!(hit) #TODO extract these two calls from here and search
        set_encoding!(hit)
        hit # { "_id", "_index", "_type", "_source" }
      end

      def delete(index, type, id, options={})
        response = request(:delete,{:index => index, :type => type, :id => id}, options)
        handle_error(response) unless response.status == 200 # ElasticSearch always returns 200 on delete, even if the object doesn't exist
        encoder.decode(response.body)
      end

      def search(index, type, query, options={})
        if query.is_a?(Hash)
          # patron cannot submit get requests with content, so if query is a hash, post it instead (assume a query hash is using the query dsl)
          response = request(:post, {:index => index, :type => type, :op => "_search"}, options, encoder.encode(query))
        else
          response = request(:get, {:index => index, :type => type, :op => "_search"}, options.merge(:q => query))
        end
        handle_error(response) unless response.status == 200
        results = encoder.decode(response.body)
        # unescape ids
        results["hits"]["hits"].each do |hit|
          unescape_id!(hit)
          set_encoding!(hit)
        end
        results # {"hits"=>{"hits"=>[{"_id", "_type", "_source", "_index", "_score"}], "total"}, "_shards"=>{"failed", "total", "successful"}}
      end

      def scroll(scroll_id, options={})
        # patron cannot submit get requests with content, so we pass the scroll_id in the parameters
        response = request(:get, {:op => "_search/scroll"}, options.merge(:scroll_id => scroll_id))
        handle_error(response) unless response.status == 200
        results = encoder.decode(response.body)
        # unescape ids
        results["hits"]["hits"].each do |hit|
          unescape_id!(hit)
          set_encoding!(hit)
        end
        results # {"hits"=>{"hits"=>[{"_id", "_type", "_source", "_index", "_score"}], "total"}, "_shards"=>{"failed", "total", "successful"}, "_scrollId"}
      end

      def count(index, type, query, options={})
        if query.is_a?(Hash)
          # patron cannot submit get requests with content, so if query is a hash, post it instead (assume a query hash is using the query dsl)
          response = request(:post, {:index => index, :type => type, :op => "_count"}, options, encoder.encode(query))
        else
          response = request(:get, {:index => index, :type => type, :op => "_count"}, options.merge(:q => query))
        end
        handle_error(response) unless response.status == 200
        encoder.decode(response.body) # {"count", "_shards"=>{"failed", "total", "successful"}}
      end

      def bulk(actions, options={})
        body = actions.inject("") { |a, s| a << encoder.encode(s) << "\n" }
        response = request(:post, {:op => '_bulk'}, options, body)
        handle_error(response) unless response.status == 200
        encoder.decode(response.body) # {"items => [ {"delete"/"create" => {"_index", "_type", "_id", "ok"}} ] }
      end
    end

    module IndexAdminProtocol
      def index_status(index_list, options={})
        standard_request(:get, {:index => index_list, :op => "_status"})
      end

      def create_index(index, create_options={}, options={})
        standard_request(:put, {:index => index}, {}, encoder.encode(create_options))
      end

      def delete_index(index, options={})
        standard_request(:delete, {:index => index})
      end

      def alias_index(operations, options={})
        standard_request(:post, {:op => "_aliases"}, {}, encoder.encode(operations))
      end

      def update_mapping(index, type, mapping, options)
        standard_request(:put, {:index => index, :type => type, :op => "_mapping"}, options, encoder.encode(mapping))
      end

      def index_mapping(index_list, options={})
        standard_request(:get, {:index => index_list, :op => "_mapping"})
      end

      def flush(index_list, options={})
        standard_request(:post, {:index => index_list, :op => "_flush"}, options, "")
      end
      
      def refresh(index_list, options={})
        standard_request(:post, {:index => index_list, :op => "_refresh"}, {}, "")
      end
      
      def snapshot(index_list, options={})
        standard_request(:post, {:index => index_list, :type => "_gateway", :op => "snapshot"}, {}, "")
      end
      
      def optimize(index_list, options={})
        standard_request(:post, {:index => index_list, :op => "_optimize"}, options, {})
      end
    end

    module ClusterAdminProtocol
      def cluster_health(index_list, options={})
        standard_request(:get, {:index => "_cluster", :type => "health", :id => index_list}, options)
      end

      def cluster_state(options={})
        standard_request(:get, {:index => "_cluster", :op => "state"})
      end

      def nodes_info(node_list, options={})
        standard_request(:get, {:index => "_cluster", :type => "nodes", :id => node_list})
      end

      def nodes_stats(node_list, options={})
        standard_request(:get, {:index => "_cluster", :type => "nodes", :id => node_list, :op => "stats"})
      end

      def shutdown_nodes(node_list, options={})
        standard_request(:post, {:index => "_cluster", :type => "nodes", :id => node_list, :op => "_shutdown"}, options, "")
      end

      def restart_nodes(node_list, options={})
        standard_request(:post, {:index => "_cluster", :type => "nodes", :id => node_list, :op =>  "_restart"}, options, "")
      end
    end

    module ProtocolHelpers
      private

      def standard_request(*args)
        response = request(*args)
        handle_error(response) unless response.status == 200
        encoder.decode(response.body)
      end

      def handle_error(response)
        raise RequestError, "(#{response.status}) #{response.body}"
      end

      # :index - one or many index names
      # :type - one or many types
      # :id - one id
      # :op - optional operation
      def generate_uri(options)
        path = ""
        path << "/#{Array(options[:index]).collect { |i| escape(i.downcase) }.join(",")}" if options[:index] && !options[:index].empty?
        path << "/" if options[:index] && options[:index].empty?
        path << "/#{Array(options[:type]).collect { |t| escape(t) }.join(",")}" if options[:type] && !options[:type].empty?
        path << "/#{Array(options[:id]).collect { |id| escape(id) }.join(",")}" if options[:id] && !options[:id].to_s.empty?
        path << "/#{options[:op]}" if options[:op]
        path
      end

      #doesn't handle arrays or hashes or what have you
      def generate_query_string(params)
        params.collect { |k,v| "#{escape(k.to_s)}=#{escape(v.to_s)}" }.join("&")
      end

      def unescape_id!(hit)
        hit["_id"] = unescape(hit["_id"])
        nil
      end

      def set_encoding!(hit)
        encode_utf8(hit["_source"]) if hit["_source"].is_a?(String)
        nil
      end

      # faster than CGI.escape
      # stolen from RSolr, who stole it from Rack
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
          string.force_encoding(::Encoding::UTF_8)
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
    end

    module BaseProtocol
      include IndexProtocol
      include IndexAdminProtocol
      include ClusterAdminProtocol
      include ProtocolHelpers

    end
  end
end
