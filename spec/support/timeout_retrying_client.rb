class TimeoutRetryingClient < ExceptionClient
  include ElasticSearch::RetryingClient
end