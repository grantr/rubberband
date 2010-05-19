module ElasticSearch
  module Transport
    module BaseProtocol
      
      # index api

      def index(index, type, id, document, options={})
        raise NotImplementedError
      end

      def get(index, type, id, options={})
        raise NotImplementedError
      end

      def delete(options)
        raise NotImplementedError
      end

      def search(index, type, query, options={})
        raise NotImplementedError
      end

      def count(index, type, query, options={})
        raise NotImplementedError
      end

      # admin index api
      
      # admin cluster api

      def nodes_info(node_list, options={})
        raise NotImplementedError
      end

      # misc
      def all_nodes
        raise NotImplementedError
      end

    end
  end
end

