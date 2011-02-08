module ElasticSearch
  module Protocol
    module Document
      def index(index, type, id, document, options={})
        body = encoder.is_encoded?(document) ? document : encoder.encode(document)
        if id.nil?
          response = request(:post, {:index => index, :type => type}, options, body)
        else
          response = request(:put, {:index => index, :type => type, :id => id}, options, body)
        end
        handle_error(response) unless response.status == 200
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

      def bulk(actions)
        body = actions.inject("") { |a, s| a << encoder.encode(s) << "\n" }
        response = request(:post, {:op => '_bulk'}, {}, body)
        handle_error(response) unless response.status == 200
        encoder.decode(response.body) # {"items => [ {"delete"/"create" => {"_index", "_type", "_id", "ok"}} ] }
      end

      def delete_by_query
        raise NotImplementedError
      end
    end
  end
end
