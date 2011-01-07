require 'test_helper'

class TypeTest < Test::Unit::TestCase
  context "Test with differents Types" do
    #TODO figure out how to have one setup and one teardown
    setup do
      @client = ElasticSearch.new('127.0.0.1:9200', :index => "twitter", :type => "tweet")
      @client.index({:user => "kimchy"}, :id => 1)
      @client.index({:user => "kimchy"}, :id => 2, :type => "grillo")
      @client.index({:user => "kimchy"}, :id => 3, :type => "cote")
      @client.index({:user => "kimchy"}, :id => 4, :index => "cotes", :type => "cote")
      @client.index({:user => "kimchy"}, :id => 5, :index => "menchos", :type => "mencho")
      @client.index({:user => "kimchy"}, :id => 6, :index => "menchos", :type => "cote")
      @client.refresh("twitter", "cotes", "menchos")
    end

    teardown do
      #@client.delete_index("twitter")
      #@client.delete_index("cotes")
      #@client.delete_index("menchos")
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
