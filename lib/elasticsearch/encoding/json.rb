require 'multi_json'

module ElasticSearch
  module Encoding
    class JSON < Base

      # MultiJson switched to a new api in 1.3
      if MultiJson.respond_to?(:adapter)
        def encode(object)
          MultiJson.dump(object)
        end

        def decode(string)
          MultiJson.load(string)
        end
      else
        def encode(object)
          MultiJson.encode(object)
        end

        def decode(string)
          MultiJson.decode(string)
        end
      end

      def is_encoded?(object)
        object.is_a?(String)
      end
    end
  end
end
