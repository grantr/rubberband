require 'test_helper'

class TypeTest < Test::Unit::TestCase
  context "Test with differents Types" do

    setup do
      @first_index = 'first-' + Time.now.to_i.to_s
      @second_index = 'second-' + Time.now.to_i.to_s
      @third_index = 'third-' + Time.now.to_i.to_s
      @username = 'kimchy' + Time.now.to_i.to_s
      @client = ElasticSearch.new('127.0.0.1:9200', :index => @first_index, :type => "tweet")
      @client.index({:user => @username}, :id => 1)
      @client.index({:user => @username}, :id => 2, :type => "grillo")
      @client.index({:user => @username}, :id => 3, :type => "cote")
      @client.index({:user => @username}, :id => 4, :index => @second_index, :type => "cote")
      @client.index({:user => @username}, :id => 5, :index => @third_index, :type => "mencho")
      @client.index({:user => @username}, :id => 6, :index => @third_index, :type => "cote")
      @client.refresh(@first_index, @second_index, @third_index)
    end

    teardown do
      @client.delete_index(@first_index)
      @client.delete_index(@second_index)
      @client.delete_index(@third_index)
    end

    should "Test different stages using indexes and types" do
      # Search in all indexes
      assert_equal @client.count(@username,{:index => "", :type => ""}), 6
      
      # Search in all types with index first
      assert_equal @client.count(@username,{:index => @first_index, :type => ""}), 3
      
      # Search in first index with types tweet,cote
      assert_equal @client.count(@username,{:index => @first_index, :type => "tweet,cote"}), 2
      
      # Search in index first and second
      @first_and_second = @first_index + ',' + @second_index  
      assert_equal @client.count(@username,{:index => @first_and_second,  :type => ""}), 4
      
      # Search in types grillo,cote of all indexes" do
      assert_equal @client.count(@username,{:index => "",  :type => "grillo,cote"}), 4
    end

  end
end
