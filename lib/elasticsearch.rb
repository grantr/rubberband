require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "elasticsearch"))

require 'encoding'
require 'transport'
require 'client'

module ElasticSearch

  def self.new(servers, options={})
    ElasticSearch::Client.new(servers, options)
  end
end
