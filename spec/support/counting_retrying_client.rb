require File.expand_path('../counting_client', __FILE__)

class CountingRetryingClient < CountingClient

  include ElasticSearch::RetryingClient

end