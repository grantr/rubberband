require 'ostruct'

module ElasticSearch
  module Api
    class Hit < OpenStruct
      undef_method :id if method_defined?(:id)

      def initialize(hit)
        hit = hit.dup
        hit.merge!(hit["_source"]) if hit["_source"]
        hit["id"] ||= hit["_id"]
        super(hit)
      end

      def attributes
        @table
      end
    end

    module Pagination
      def current_page
        (@options[:page].respond_to?(:empty?) ? @options[:page].empty? : !@options[:page]) ? 1 : @options[:page].to_i
      end

      def next_page
        current_page >= total_pages ? nil : current_page + 1
      end

      def previous_page
        current_page == 1 ? nil : current_page - 1
      end

      def per_page
        @options[:per_page] || 10
      end

      def total_pages
        (total_entries / per_page.to_f).ceil
      end
      alias_method :page_count, :total_pages
    end


    class Hits
      include Pagination
      attr_reader :hits, :total_entries, :_shards, :response, :facets, :scroll_id

      def initialize(response, options={})
        @response = response
        @options = options
        @total_entries = response["hits"]["total"]
        @_shards = response["_shards"]
        @facets = response["facets"]
        @scroll_id = response["_scroll_id"] || response["_scrollId"]
        populate(@options[:ids_only])
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
        @hits = @response["hits"]["hits"].collect { |h| ids_only ? h["_id"] : Hit.new(h) }
      end
    end
  end
end
