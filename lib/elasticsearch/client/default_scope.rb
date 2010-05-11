module ElasticSearch
  module Api
    module DefaultScope
      def default_index
        @default_index ||= @options[:index]
      end

      def default_index=(index)
        @default_index = index
      end

      def default_type
        @default_type ||= @options[:type]
      end

      def default_type=(type)
        @default_type = type
      end

      private

      def set_default_scope!(options)
        options[:index] ||= default_index
        options[:type] ||= default_type
        nil
      end
    end
  end
end
