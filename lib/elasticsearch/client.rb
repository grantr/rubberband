require 'client/abstract_client'
require 'client/retrying_client'

require 'client/index'
require 'client/admin_index'
require 'client/admin_cluster'

module ElasticSearch
  class Client < AbstractClient
    include RetryingClient
    include Api::Index
    include Api::Admin::Index
    include Api::Admin::Cluster

  end
end
