module ElasticSearch
  module Protocol
    autoload :Document, 'protocol/document'
    autoload :Query,    'protocol/query'
    autoload :Index,    'protocol/index'
    autoload :Cluster,  'protocol/cluster'

    autoload :Helpers,  'protocol/helpers'
  end
end
