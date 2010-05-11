require 'ostruct'

module ElasticSearch
  module Api
    class Hit < OpenStruct
      undef_method :id

      def initialize(hit)
        hit = hit.dup
        hit.merge!(hit.delete("_source"))
        hit["id"] ||= hit["_id"]
        super(hit)
      end
    end

    class Hits
      attr_reader :hits, :total_entries, :_shards, :response

      def initialize(response)
        @response = response
        @total_entries = response["hits"]["total"]
        @_shards = response["_shards"]
        populate
      end

      def to_a
        @hits
      end

      def freeze
        @hits.freeze
        super
      end

      def method_missing(method, *args, &block)
        @hits.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || @hits.respond_to?(method, include_private)
      end

      private

      def populate
        @hits = @response["hits"]["hits"].collect { |h| Hit.new(h).freeze }
      end
    end
  end
end
