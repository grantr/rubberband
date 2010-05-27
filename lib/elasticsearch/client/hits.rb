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
        @table.freeze
      end

      def attributes
        @table
      end
    end

    class Hits
      attr_reader :hits, :total_entries, :_shards, :response, :facets

      def initialize(response, ids_only=false)
        @response = response
        @total_entries = response["hits"]["total"]
        @_shards = response["_shards"]
        @facets = response["facets"]
        populate(ids_only)
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

      def populate(ids_only=false)
        @hits = @response["hits"]["hits"].collect { |h| ids_only ? h["_id"] : Hit.new(h).freeze }
      end
    end
  end
end
