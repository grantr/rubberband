module ElasticSearch
  module Transport
    autoload :Base, 'transport/base'

    autoload :HTTP, 'transport/http'
    autoload :Thrift, 'transport/thrift'
    autoload :Memcached, 'transport/memcached'
  end
end
