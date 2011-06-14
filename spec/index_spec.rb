require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "index ops" do
  before(:all) do
    @first_index = 'first-' + Time.now.to_i.to_s
    @client = ElasticSearch.new('127.0.0.1:9200', :index => @first_index, :type => "tweet")
  end

  after(:all) do
    @client.delete_index(@first_index)
    sleep(1)
  end

  it "should get and delete a document" do
    @client.index({:foo => "bar"}, :id => "1", :refresh => true)

    @client.get("1").foo.should == "bar"
    @client.delete("1", :refresh => true).should be_true
    @client.get("1").should be_nil
  end

  it 'should search and count documents' do
    @client.index({:foo => "bar"}, :id => "1")
    @client.index({:foo => "baz"}, :id => "2")
    @client.index({:foo => "baz also"}, :id => "3")
    @client.refresh(@first_index)

    @client.search("bar").should have(1).items
    @client.count("bar").should == 1

    @client.search(:query => { :term => { :foo => 'baz' }}).should have(2).items
    @client.count(:term => { :foo => 'baz' }).should == 2
  end

  it 'should return ids when given :ids_only' do
    @client.index({:socks => "stripey"}, :id => "5")
    @client.index({:stripey => "stripey too"}, :id => "6")
    @client.refresh

    results = @client.search({:query => { :field => { :socks => 'stripey' }}}, :ids_only => true)
    results.should include("5")
  end

  it 'should delete by query' do
    @client.index({:deleted => "bar"}, :id => "d1")
    @client.index({:deleted => "bar"}, :id => "d2")
    @client.refresh

    @client.count(:term => { :deleted => 'bar'}).should == 2
    @client.delete_by_query(:term => { :deleted => 'bar' })
    @client.refresh
    @client.count(:term => { :deleted => 'bar'}).should == 0
  end
end
