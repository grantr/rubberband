require 'client/abstract_client'
require 'client/retrying_client'
require 'client/auto_discovering_client'

require 'client/default_scope'
require 'api/document'
require 'api/query'
require 'api/index'
require 'api/cluster'

module ElasticSearch
  class Client < AbstractClient
    include RetryingClient
    include AutoDiscoveringClient
    include DefaultScope

    include Api::Document
    include Api::Query
    include Api::Index
    include Api::Cluster

  end
end
