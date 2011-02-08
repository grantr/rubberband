module ElasticSearch
  module Protocol
    module Query
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

      def more_like_this
        raise NotImplementedError
      end

      def scroll(scroll_id)
        response = request(:get, {:op => "_search/scroll"}, {:scroll_id => scroll_id })
        handle_error(response) unless response.status == 200
        results = encoder.decode(response.body)
        # unescape ids
        results["hits"]["hits"].each do |hit|
          unescape_id!(hit)
          set_encoding!(hit)
        end
        results # {"hits"=>{"hits"=>[{"_id", "_type", "_source", "_index", "_score"}], "total"}, "_shards"=>{"failed", "total", "successful"}, "_scrollId"}
      end

    end
  end
end
