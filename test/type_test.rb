require 'test_helper'

class TypeTest < Test::Unit::TestCase
  context "Test with differents Types" do
    setup do
      client = ElasticSearch.new('127.0.0.1:9200', :index => "twitter", :type => "tweet")
      client.index({:user => "kimchy"}, :id => 1)
      client = ElasticSearch.new('127.0.0.1:9200', :index => "twitter", :type => "grillo")
      client.index({:user => "kimchy"}, :id => 4)
      client = ElasticSearch.new('127.0.0.1:9200', :index => "twitter", :type => "cote")
      client.index({:user => "kimchy"}, :id => 3)
      client = ElasticSearch.new('127.0.0.1:9200', :index => "cotes", :type => "cote")
      client.index({:user => "kimchy"}, :id => 2)
      client = ElasticSearch.new('127.0.0.1:9200', :index => "menchos", :type => "mencho")
      client.index({:user => "kimchy"}, :id => 5)
      client = ElasticSearch.new('127.0.0.1:9200', :index => "menchos", :type => "cote")
      client.index({:user => "kimchy"}, :id => 6)
      # I need sleep in order to refresh the indexes....at least 1 second?
      sleep(1)
      @client = ElasticSearch.new('127.0.0.1:9200', :index => "twitter", :type => "tweet")
    end
    
    should "search in all indexes" do
      assert_equal @client.count("kimchy",{:index => "", :type => ""}), 6
    end
    
    should "search in all types with index twitter" do
      assert_equal @client.count("kimchy",{:index => "twitter", :type => ""}), 3
    end
    
    should "search in index twitter with types tweet,cote" do
      assert_equal @client.count("kimchy",{:index => "twitter", :type => "tweet,cote"}), 2
    end
    
    should "search in index twitter,cotes" do
      assert_equal @client.count("kimchy",{:index => "twitter,cotes",  :type => ""}), 4
    end
    
    should "search in types grillo,cote of all indexes" do
      assert_equal @client.count("kimchy",{:index => "",  :type => "grillo,cote"}), 4
    end
    
  end
end
