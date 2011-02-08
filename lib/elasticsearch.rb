require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "elasticsearch"))

module ElasticSearch

  autoload :Encoding,  'encoding'
  autoload :Transport, 'transport'
  autoload :Client,    'client'
  autoload :Api,       'api'
  autoload :Protocol,  'protocol'

  def self.new(servers, options={})
    ElasticSearch::Client.new(servers, options)
  end
end
