require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "basic ops" do
  before(:all) do
    @first_index = 'first-' + Time.now.to_i.to_s
    @client = ElasticSearch.new('127.0.0.1:9200', :index => @first_index, :type => "tweet")
  end

  after(:all) do
    @client.delete_index(@first_index)
    sleep(1)
  end

  it "should get and update mappings" do
    @client.index({:foo => "bar"}, :id => "1", :refresh => true)

    @client.index_mapping(@first_index).should == {@first_index => {"tweet" => { "properties" => { "foo" => {"type" => "string" }}}}}
    @client.update_mapping({"tweet" => {:properties => {:bar => {:type => "string"}}}})
    @client.index_mapping(@first_index).should == {@first_index => {"tweet" => { "properties" => { "foo" => {"type" => "string" }, "bar" => { "type" => "string"}}}}}
  end
end
