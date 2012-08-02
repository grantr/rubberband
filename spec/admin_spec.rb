require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "basic ops" do
  before(:all) do
    @first_index = 'first-' + Time.now.to_i.to_s
    @client = ElasticSearch.new('http://127.0.0.1:9200', :index => @first_index, :type => "tweet")
  end

  after(:all) do
    @client.delete_index(@first_index)
    sleep(1)
  end

  it "should get and update mappings" do
    @client.index({:foo => "bar"}, :id => "1", :refresh => true)

    @client.update_mapping({"tweet" => {:properties => {:bar => {:type => "string"}}}})
    @client.index_mapping(@first_index).should == {@first_index => {"tweet" => { "properties" => { "foo" => {"type" => "string" }, "bar" => { "type" => "string"}}}}}
    # default should also work
    @client.index_mapping.should == {@first_index => {"tweet" => { "properties" => { "foo" => {"type" => "string" }, "bar" => { "type" => "string"}}}}}
  end

  it "should get and update settings" do
    @client.update_settings("index" => {"refresh_interval" => 30})
    @client.get_settings(@first_index)[@first_index]["settings"].should include("index.refresh_interval" => "30")
    # default should also work
    @client.get_settings[@first_index]["settings"].should include("index.refresh_interval" => "30")
  end

  it "should get and update aliases" do
    @client.alias_index(:add => { @first_index => "#{@first_index}-alias" })
    result = @client.get_aliases(@first_index)
    result[@first_index]["aliases"].keys.should include("#{@first_index}-alias")
    @client.alias_index(:add => { @first_index => "#{@first_index}-alias2" }, :remove => { @first_index => "#{@first_index}-alias" })
    result = @client.get_aliases(@first_index)
    result[@first_index]["aliases"].keys.should_not include("#{@first_index}-alias")
    result[@first_index]["aliases"].keys.should include("#{@first_index}-alias2")
    # default should also work
    result = @client.get_aliases
    result[@first_index]["aliases"].keys.should_not include("#{@first_index}-alias")
    result[@first_index]["aliases"].keys.should include("#{@first_index}-alias2")
  end

  it 'should get aliases for non-default index' do
    second_index = 'second-' + Time.now.to_i.to_s
    @client.create_index(second_index)
    @client.alias_index(:add => { second_index => "#{second_index}-alias" })
    result = @client.get_aliases(second_index)
    result[second_index]["aliases"].keys.should include("#{second_index}-alias")
  end
end
