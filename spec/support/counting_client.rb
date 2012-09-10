class CountingClient < ElasticSearch::AbstractClient

  attr_accessor :connect_calls, :disconnect_calls, :execute_calls

  def initialize(servers_or_url, options={})
    super
    @connect_calls = 0
    @disconnect_calls = 0
    @execute_calls = 0
  end

  def connect!
    @connect_calls += 1
  end

  def disconnect!
    @disconnect_calls += 1
  end

  def execute(method_name, *args)
    @execute_calls += 1
  end

end