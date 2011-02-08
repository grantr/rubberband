module ElasticSearch
  class NoServersAvailable < StandardError; end

  class RetryableError < StandardError; end
  class FatalError < StandardError; end

  class ConnectionFailed < RetryableError; end
  class HostResolutionError < RetryableError; end
  class TimeoutError < RetryableError; end
  class RequestError < FatalError; end
end
