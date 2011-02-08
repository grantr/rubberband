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

      def extract_scope(options)
        options = options.dup
        index = options.delete(:index) || default_index
        type = options.delete(:type) || default_type
        [index, type, options]
      end

      def extract_required_scope(options)
        scope = extract_scope(options)
        raise "index and type or defaults required" unless scope[0] && scope[1]
        scope
      end
    end
  end
end
