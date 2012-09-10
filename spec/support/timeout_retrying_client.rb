require File.expand_path('../exception_client', __FILE__)

class TimeoutRetryingClient < ExceptionClient
  include ElasticSearch::RetryingClient
end