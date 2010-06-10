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
      def index_status(index_list, options={})
        raise NotImplementedError
      end

      def create_index(index, create_options={}, options={})
        raise NotImplementedError
      end

      def delete_index(index, options={})
        raise NotImplementedError
      end

      def alias_index(operations, options={})
        raise NotImplementedError
      end

      def update_mapping(index, type, mapping, options)
        raise NotImplementedError
      end

      def flush(index_list, options={})
        raise NotImplementedError
      end

      def refresh(index_list, options={})
        raise NotImplementedError
      end

      def snapshot(index_list, options={})
        raise NotImplementedError
      end

      def optimize(index_list, options={})
        raise NotImplementedError
      end


      # admin cluster api
      def cluster_health(index_list, options={})
        raise NotImplementedError
      end

      def cluster_state(options={})
        raise NotImplementedError
      end

      def nodes_info(node_list, options={})
        raise NotImplementedError
      end

      def nodes_stats(node_list, options={})
        raise NotImplementedError
      end

      def shutdown_nodes(node_list, options={})
        raise NotImplementedError
      end

      def restart_nodes(node_list, options={})
        raise NotImplementedError
      end

      # misc
      def all_nodes
        raise NotImplementedError
      end

    end
  end
end

