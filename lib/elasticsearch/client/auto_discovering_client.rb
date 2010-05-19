module ElasticSearch
  module AutoDiscoveringClient

    AUTO_DISCOVERING_DEFAULTS = {
      :auto_discovery => true
    }.freeze

    def initialize(servers, options={})
      super
      @options = AUTO_DISCOVERING_DEFAULTS.merge(@options)
      if @options[:auto_discovery]
        auto_discover_nodes!
      end
    end

    #TODO how to autodiscover on reconnect? don't want to overwrite methods of RetryingClient
    def auto_discover_nodes!
      @server_list = execute(:all_nodes)
    end
  end
end
