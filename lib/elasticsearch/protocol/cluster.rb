module ElasticSearch
  module Protocol
    module Cluster
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
  end
end
