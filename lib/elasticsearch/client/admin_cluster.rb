module ElasticSearch
  module Api
    module Admin
      module Cluster
        def nodes_info(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          execute(:nodes_info, args.flatten, options)
        end

      end
    end
  end
end
