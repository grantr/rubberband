require "transport/base_protocol"
require "transport/base"

module ElasticSearch
  class ConnectionFailed < RetryableError; end
  class HostResolutionError < RetryableError; end
  class TimeoutError < RetryableError; end
  class RequestError < FatalError; end

  module Transport
    autoload :HTTP, 'transport/http'
  end
end
