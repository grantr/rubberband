require 'client/hits'

module ElasticSearch
  module Api
    module Index
      def index(document, options={})
        set_default_scope!(options)
        raise "index and type or defaults required" unless options[:index] && options[:type]
        # type
        # index
        # id (optional)
        # op_type (optional)
        # timeout (optional)
        # document (optional)

        result = execute(:index, options[:index], options[:type], options[:id], document, options)
        if result["ok"]
          result["_id"]
        else
          false
        end
      end

      def get(id, options={})
        set_default_scope!(options)
        raise "index and type or defaults required" unless options[:index] && options[:type]
        # index
        # type
        # id
        # fields
        
        hit = execute(:get, options[:index], options[:type], id, options)
        if hit
          Hit.new(hit).freeze
        end
      end

      def delete(id, options={})
        set_default_scope!(options)
        raise "index and type or defaults required" unless options[:index] && options[:type]
        result = execute(:delete, options[:index], options[:type], id, options)
        result["ok"]
      end

      #df	 The default field to use when no field prefix is defined within the query.
      #analyzer	 The analyzer name to be used when analyzing the query string.
      #default_operator	 The default operator to be used, can be AND or OR. Defaults to OR.
      #explain	 For each hit, contain an explanation of how to scoring of the hits was computed.
      #fields	 The selective fields of the document to return for each hit (fields must be stored), comma delimited. Defaults to the internal _source field.
      #field	 Same as fields above, but each parameter contains a single field name to load. There can be several field parameters.
      #sort	 Sorting to perform. Can either be in the form of fieldName, or fieldName:reverse (for reverse sorting). The fieldName can either be an actual field within the document, or the special score name to indicate sorting based on scores. There can be several sort parameters (order is important).
      #from	 The starting from index of the hits to return. Defaults to 0.
      #size	 The number of hits to return. Defaults to 10.
      #search_type	 The type of the search operation to perform. Can be dfs_query_then_fetch, dfs_query_and_fetch, query_then_fetch, query_and_fetch. Defaults to query_then_fetch.
      def search(query, options={})
        set_default_scope!(options)

        #TODO this doesn't work for facets, because they have a valid query key as element. need a list of valid toplevel keys in the search dsl
        #query = {:query => query} if query.is_a?(Hash) && !query[:query] # if there is no query element, wrap query in one

        search_options = slice_hash(options, :df, :analyzer, :default_operator, :explain, :fields, :field, :sort, :from, :size, :search_type, :limit, :per_page, :page, :offset)

        search_options[:size] ||= search_options[:per_page] if search_options[:per_page]
        search_options[:size] ||= search_options[:limit] if search_options[:limit]
        search_options[:from] ||= search_options[:size] * (search_options[:page]-1) if search_options[:page] && search_options[:page].to_i > 1
        search_options[:from] ||= search_options[:offset] if search_options[:offset]

        search_options[:fields] = "_id" if options[:ids_only]

        response = execute(:search, options[:index], options[:type], query, search_options)
        Hits.new(response, slice_hash(options, :per_page, :page, :ids_only)).freeze #ids_only returns array of ids instead of hits
      end

      #df	 The default field to use when no field prefix is defined within the query.
      #analyzer	 The analyzer name to be used when analyzing the query string.
      #default_operator	 The default operator to be used, can be AND or OR. Defaults to OR.
      def count(query, options={})
        set_default_scope!(options)

        count_options = slice_hash(options, :df, :analyzer, :default_operator)
        response = execute(:count, options[:index], options[:type], query, count_options)
        response["count"].to_i #TODO check if count is nil
      end


      private

      def slice_hash(hash, *keys)
        h = {}
        keys.each { |k| h[k] = hash[k] if hash.has_key?(k) }
        h
      end

    end
  end
end
