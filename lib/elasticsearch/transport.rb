require "transport/base_protocol"
require "transport/base"

module ElasticSearch
  module Transport
    autoload :HTTP, 'transport/http'
  end
end
