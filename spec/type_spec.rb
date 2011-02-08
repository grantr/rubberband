require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "type and index parameters" do
  before(:all) do
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

  after(:all) do
    @client.delete_index(@first_index)
    @client.delete_index(@second_index)
    @client.delete_index(@third_index)
    sleep(1)
  end

  it "should search in all indexes" do
    @client.count(@username,{:index => "", :type => ""}).should == 6
  end

  it "should search in all types with index first" do
    @client.count(@username,{:index => @first_index, :type => ""}).should == 3
  end
 
  it "should search in first index with types tweet,cote" do
    @client.count(@username,{:index => @first_index, :type => "tweet,cote"}).should == 2
  end

  it "should search in index first and second" do
    @first_and_second = @first_index + ',' + @second_index  
    @client.count(@username,{:index => @first_and_second,  :type => ""}).should == 4
  end

  it "should search in types grillo,cote of all indexes" do
    @client.count(@username,{:index => "",  :type => "grillo,cote"}).should == 4
  end
end
