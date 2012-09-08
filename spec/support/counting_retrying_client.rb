class CountingRetryingClient < CountingClient

  include ElasticSearch::RetryingClient

end