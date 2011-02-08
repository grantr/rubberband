module ElasticSearch
  module Protocol
    module Index
      def index_status(index_list, options={})
        standard_request(:get, {:index => index_list, :op => "_status"})
      end

      def create_index(index, create_options={}, options={})
        standard_request(:put, {:index => index}, {}, encoder.encode(create_options))
      end

      def delete_index(index, options={})
        standard_request(:delete, {:index => index})
      end

      def put_aliases(operations, options={})
        standard_request(:post, {:op => "_aliases"}, {}, encoder.encode(operations))
      end

      def put_mapping(index, type, mapping, options)
        standard_request(:put, {:index => index, :type => type, :op => "_mapping"}, options, encoder.encode(mapping))
      end

      def get_mapping(index_list, options={})
        standard_request(:get, {:index => index_list, :op => "_mapping"})
      end

      def flush(index_list, options={})
        standard_request(:post, {:index => index_list, :op => "_flush"}, options, "")
      end
      
      def refresh(index_list, options={})
        standard_request(:post, {:index => index_list, :op => "_refresh"}, {}, "")
      end
      
      def snapshot(index_list, options={})
        standard_request(:post, {:index => index_list, :type => "_gateway", :op => "snapshot"}, {}, "")
      end
      
      def optimize(index_list, options={})
        standard_request(:post, {:index => index_list, :op => "_optimize"}, options, {})
      end
    end
  end
end
