module ElasticSearch
  module Api
    module Document

      # document
      # type
      # index
      # id (optional)
      # op_type (optional)
      # timeout (optional)
      def index(document, options={})
        index, type, options = extract_required_scope(options)

        id = options.delete(:id)
        if @batch
          @batch << { :index => { :_index => index, :_type => type, :_id => id }}
          @batch << document
        else
          execute(:index, index, type, id, document, options)
        end
      end

      def get(id, options={})
        index, type, options = extract_required_scope(options)
        # index
        # type
        # id
        # fields
        
        execute(:get, index, type, id, options)
      end

      def delete(id, options={})
        index, type, options = extract_required_scope(options)

        if @batch
          @batch << { :delete => { :_index => index, :_type => type, :_id => id }}
        else
          execute(:delete, index, type, id, options)
        end
      end

      # Starts a bulk operation batch and yields self. Index and delete requests will be 
      # queued until the block closes, then sent as a single _bulk call.
      def bulk
        @batch = []
        yield(self)
        response = execute(:bulk, @batch)
      ensure
        @batch = nil
      end

    end
  end
end
