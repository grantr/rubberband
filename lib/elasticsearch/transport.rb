module ElasticSearch
  class ConnectionFailed < RetryableError; end
  class HostResolutionError < RetryableError; end
  class TimeoutError < RetryableError; end
  class RequestError < FatalError; end

  module Transport
    autoload :Base, 'transport/base'

    autoload :HTTP, 'transport/http'
    autoload :Thrift, 'transport/thrift'
    autoload :Memcached, 'transport/memcached'
  end
end
