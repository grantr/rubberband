require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "elasticsearch"))

require 'encoding'
require 'transport'
require 'client'

module ElasticSearch

  def self.new(servers_or_url, options={})
    ElasticSearch::Client.new(servers_or_url, options)
  end
end
