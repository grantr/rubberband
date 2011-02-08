require 'test_helper'

class BasicTest < Test::Unit::TestCase
  context "basic ops" do

    setup do
      @first_index = 'first-' + Time.now.to_i.to_s
      @client = ElasticSearch.new('127.0.0.1:9200', :index => @first_index, :type => "tweet")
    end

    teardown do
      @client.delete_index(@first_index)
      sleep(1)
    end

    #TODO this test fails randomly, there's some kind of timing issue here
    should "get and update mappings" do
      @client.index({:foo => "bar"}, :id => "1", :refresh => true)
      
      assert_equal({@first_index => {"tweet" => { "properties" => { "foo" => {"type" => "string" }}}}}, @client.index_mapping(@first_index))
      @client.update_mapping({"tweet" => {:properties => {:bar => {:type => "string"}}}})
      assert_equal({@first_index => {"tweet" => { "properties" => { "foo" => {"type" => "string" }, "bar" => { "type" => "string"}}}}}, @client.index_mapping(@first_index))
    end
  end
end
