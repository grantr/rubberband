require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "elasticsearch"))

require 'errors'

module ElasticSearch

  autoload :Encoding,  'encoding'
  autoload :Client,    'client'
  autoload :Transport, 'transport'
  autoload :Api,       'api'
  autoload :Protocol,  'protocol'

  def self.new(servers, options={})
    ElasticSearch::Client.new(servers, options)
  end
end
