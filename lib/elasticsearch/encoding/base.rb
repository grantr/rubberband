module ElasticSearch
  module Encoding
    class Base
      def encode(object)
        raise "not implemented"
      end

      def decode(string)
        raise "not implemented"
      end

      def is_encoded?(object)
        raise "not implemented"
      end
    end
  end
end
