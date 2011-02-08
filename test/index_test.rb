require 'test_helper'

class IndexTest < Test::Unit::TestCase
  context "index ops" do

    setup do
      @first_index = 'first-' + Time.now.to_i.to_s
      @client = ElasticSearch.new('127.0.0.1:9200', :index => @first_index, :type => "tweet")
    end

    teardown do
      @client.delete_index(@first_index)
      sleep(1)
    end

    should "do basic ops on a document" do
      @client.index({:foo => "bar"}, :id => "1", :refresh => true)

      assert_equal "bar", @client.get("1").foo
      assert_equal true, @client.delete("1", :refresh => true)
      assert_equal nil, @client.get("1")

      @client.index({:foo => "bar"}, :id => "1")
      @client.index({:foo => "baz"}, :id => "2")
      @client.index({:foo => "baz also"}, :id => "3")
      @client.refresh(@first_index)

      assert_equal 1, @client.search("bar").size
      assert_equal 1, @client.count("bar")

      assert_equal 2, @client.search(:query => { :term => { :foo => 'baz' }}).size
      assert_equal 2, @client.count(:term => { :foo => 'baz' })
    end
  end
end
