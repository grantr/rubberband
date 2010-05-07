module ElasticSearch
  class AbstractClient

    DEFAULTS = {
      :transport => ElasticSearch::Transport::HTTP
    }.freeze

    def initialize(servers, options={})
      @options = DEFAULTS.merge(options)
      @server_list = Array(servers)
      @current_server = @server_list.first
    end

    def inspect
      "<#{self.class} @current_server=#{@current_server} @server_list=#{@server_list.inspect} @options=#{@options.inspect}>"
    end

    def connect!
      @connection = @options[:transport].new(@current_server, @options)
      @connection.connect!
    end

    def disconnect!
      @connection.close rescue nil
      @connection = nil
      @current_server = nil
    end

    def execute(method_name, *args)
      connect! unless @connection
      @connection.send(method_name, *args)
    end
  end
end
