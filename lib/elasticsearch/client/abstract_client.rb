require 'uri'

module ElasticSearch
  class AbstractClient

    DEFAULTS = {
      :transport => ElasticSearch::Transport::HTTP
    }.freeze

    def initialize(servers_or_url, options={})
      @options = DEFAULTS.merge(options)
      @server_list, @default_index, @default_type = extract_server_list_and_defaults(servers_or_url)
      @current_server = @server_list.first
    end

    def extract_server_list_and_defaults(servers_or_url)
      default_index = default_type = nil
      servers = Array(servers_or_url).collect do |server|
        uri = URI.parse(server)
        _, default_index, default_type = uri.path.split("/")
        uri.path = "" # is this expected behavior of URI? may be dangerous to rely on
        uri.to_s
      end
      [servers, default_index, default_type]
    end

    def current_server
      @current_server
    end

    def servers
      @server_list
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
