require 'yajl'

module ElasticSearch
  module Encoding
    class JSON < Base
      def encode(object)
        Yajl::Encoder.encode(object)
      end

      def decode(string)
        Yajl::Parser.parse(string)
      end

      def is_encoded?(object)
        object.is_a?(String)
      end
    end
  end
end
