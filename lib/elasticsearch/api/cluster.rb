module ElasticSearch
  module Api
    module Cluster
      PSEUDO_NODES = [:all, :local, :master]

      # list of indices, or all indices (default)
      # options: level (cluster (default), indices, shards), wait_for_status, wait_for_relocating_shards, timeout
      def cluster_health(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        execute(:cluster_health, args.flatten, options)
      end

      def cluster_state(options={})
        execute(:cluster_state, options)
      end

      # list of nodes, or all nodes (default)
      # no options
      def nodes_info(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        execute(:nodes_info, args.flatten, options)
      end

      # list of nodes, or all nodes (default)
      # no options
      def nodes_stats(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        execute(:nodes_stats, args.flatten, options)
      end

      # list of nodes, or :local, :master, :all
      # if no nodes, then do nothing (to avoid accidental cluster shutdown)
      # options: delay
      def shutdown_nodes(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        return false if args.empty?
        nodes = args.flatten
        nodes.collect! { |n| PSEUDO_NODES.include?(n) ? "_#{n}" : n }
        execute(:shutdown_nodes, nodes, options)
      end

      # list of nodes, or :local, :master, :all
      # if no nodes, then do nothing (to avoid accidental cluster shutdown)
      # options: delay
      def restart_nodes(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        return false if args.empty?
        nodes = args.flatten
        nodes.collect! { |n| PSEUDO_NODES.include?(n) ? "_#{n}" : n }
        execute(:restart_nodes, nodes, options)
      end
    end
  end
end
