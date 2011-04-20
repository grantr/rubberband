require "transport/base_protocol"
require "transport/base"

module ElasticSearch
  class ConnectionFailed < FatalError; end
  class HostResolutionError < RetryableError; end
  class TimeoutError < RetryableError; end
  class RequestError < FatalError; end

  module Transport
    autoload :HTTP, 'transport/http'
    autoload :Thrift, 'transport/thrift'
    autoload :Memcached, 'transport/memcached'
  end
end
