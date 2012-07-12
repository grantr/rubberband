require 'uri'

module ElasticSearch
  class AbstractClient

    DEFAULTS = {
      :transport => ElasticSearch::Transport::HTTP
    }.freeze

    attr_accessor :servers, :current_server, :connection

    def initialize(servers_or_url, options={}, &block)
      @options = DEFAULTS.merge(options)
      @servers, @default_index, @default_type = extract_servers_and_defaults(servers_or_url)
      @current_server = @servers.first
    end

    def extract_servers_and_defaults(servers_or_url)
      default_index = default_type = nil
      given_servers = Array(servers_or_url).collect do |server|
        begin
          uri = URI.parse(server)
          _, default_index, default_type = uri.path.split("/")
          uri.path = "" # is this expected behavior of URI? may be dangerous to rely on
          uri.to_s
        rescue URI::InvalidURIError
          server
        end
      end
      [given_servers, default_index, default_type]
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
