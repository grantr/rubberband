require File.expand_path('../counting_client', __FILE__)

class ExceptionClient < CountingClient

  def initialize(servers_or_url, options={})
    super
    @exception = options[:exception] || ElasticSearch::TimeoutError
   end

  def connect!
    super
    raise @exception
  end

  def execute(method_name, *args)
    super
    raise @exception
  end

end
