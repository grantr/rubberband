# mostly ripped from thrift_client

module ElasticSearch
  class NoServersAvailable < StandardError; end

  module RetryingClient

    RETRYING_DEFAULTS = {
      :randomize_server_list => true,
      :retries => nil,
      :server_retry_period => 1,
      :server_max_requests => nil,
      :retry_overrides => {}
    }.freeze

    # use cluster status to get server list
    def initialize(servers_or_url, options={})
      super
      @options = RETRYING_DEFAULTS.merge(@options)
      @retries = options[:retries] || @servers.size
      @connect_retries_count = 0
      @execute_retries_count = 0
      @request_count = 0
      @max_requests = @options[:server_max_requests]
      @retry_period = @options[:server_retry_period]
      rebuild_live_server_list!
    end

    def connect!
      @current_server = next_server
      clear_connect_retries_count_after do
        super
      end
    rescue ElasticSearch::RetryableError => exception
      increment_or_raise_on_connect_retry( exception )
      retry
    end

    def disconnect!
      # Keep live servers in the list if we have a retry period. Otherwise,
      # always eject, because we will always re-add them.
      if @retry_period && @current_server
        @live_server_list.unshift(@current_server)
      end

      super
      @request_count = 0
    end

    #TODO this can spin indefinitely if timeout > retry_period
    def next_server
      if @retry_period
        rebuild_live_server_list! if Time.now > @last_rebuild + @retry_period
        raise NoServersAvailable, "No live servers in #{@servers.inspect} since #{@last_rebuild.inspect}." if @live_server_list.empty?
      elsif @live_server_list.empty?
        rebuild_live_server_list!
      end
      @live_server_list.shift
    end

    def rebuild_live_server_list!
      @last_rebuild = Time.now
      if @options[:randomize_server_list]
        @live_server_list = @servers.sort_by { rand }
      else
        @live_server_list = @servers.dup
      end
    end

    def execute(method_name, *args)
      disconnect_on_max! if @max_requests and @request_count >= @max_requests
      @request_count += 1
      begin
        clear_execute_retries_count_after do
          super
        end
      rescue ElasticSearch::RetryableError => exception
        disconnect!
        increment_or_raise_on_execute_retry( exception )
        retry
      end
    end

    def disconnect_on_max!
      @live_server_list.push(@current_server)
      disconnect!
    end

    protected

    def clear_connect_retries_count_after
      result = yield
      @connect_retries_count = 0
      result
    end

    def clear_execute_retries_count_after
      result = yield
      @execute_retries_count = 0
      @connect_retries_count = 0
      result
    end

    def increment_or_raise_on_connect_retry( exception )
      if @retries <= @connect_retries_count
        @connect_retries_count = 0
        @execute_retries_count = 0
        raise exception
      else
        @connect_retries_count += 1
      end
    end

    def increment_or_raise_on_execute_retry( exception )
      if @retries <= @execute_retries_count
        @execute_retries_count = 0
        @connect_retries_count = 0
        raise exception
      else
        @execute_retries_count += 1
      end
    end

  end
end
