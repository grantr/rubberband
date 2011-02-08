module ElasticSearch
  class RetryableError < StandardError; end
  class FatalError < StandardError; end

  module Transport

    DEFAULTS = {
      :encoder => ElasticSearch::Encoding::JSON
    }.freeze

    class Base
      include Protocol::Document
      include Protocol::Query
      include Protocol::Index
      include Protocol::Cluster
      include Protocol::Helpers

      attr_accessor :server, :options

      def initialize(server, options={})
        @server = server
        @options = DEFAULTS.merge(options)
      end

      def connect!
        raise NotImplementedError
      end

      def close
      end

      def encoder
        @encoder ||= @options[:encoder].new
      end

      def all_nodes
        raise NotImplementedError
      end

      def request(method, operation, params={}, body=nil, headers={})
        raise NotImplementedError
      end
    end
  end
end
