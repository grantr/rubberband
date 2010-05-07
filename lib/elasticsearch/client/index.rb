module ElasticSearch
  module Api
    module Index
      def index(index_name, type, id, document, options={})
        # type
        # index
        # id (optional)
        # op_type
        # timeout
        # document

        execute(:index, index_name, type, id, document, options)
      end

      def get(index_name, type, id, options={})
        # index
        # type
        # id
        # fields
        
        execute(:get, index_name, type, id, options)
      end


      def search(options)
        puts "not implemented"
      end

      def delete(options)
        puts "not implemented"
      end

    end
  end
end
