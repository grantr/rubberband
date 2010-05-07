module ElasticSearch
  module Transport
    module BaseProtocol
      def index(index, type, id, document, options={})
        raise "not implemented"
      end

      def get(index, type, id, options={})
        raise "not implemented"
      end

      def search(options)
        raise "not implemented"
      end

      def delete(options)
        raise "not implemented"
      end
    end
  end
end

