require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ElasticSearch::Api::Hit do
  let(:response) { {"_source" => {"foo" => "bar"}, "_id" => "1"} }

  subject { described_class.new(response) }

  its(:id) { should == response["_id"] }

  its(:attributes) { should be_frozen }

  it "should set hit attributes" do
    subject.foo.should == response["_source"]["foo"]
  end
end

describe ElasticSearch::Api::Hits do
  context "unpaginated" do
    let(:response) do
      {
        "_shards"=>{"total"=>30, "successful"=>30, "failed"=>0}, 
        "hits"=>{"total"=>2, "max_score"=>1.0, "hits"=>[
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"1", "_score"=>1.0, "_source"=>{"foo" => "bar"}},
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"2", "_score"=>1.0, "_source"=>{"foo" => "baz"}}
      ]}}
    end

    subject { described_class.new(response) }

    it { should respond_to(:response) }

    its(:total_entries) { should == response["hits"]["hits"].size }

    it "should instantiate hits in order" do
      response["hits"]["hits"].each_with_index do |hit, i|
        subject.hits[i].should == ElasticSearch::Api::Hit.new(hit)
      end
    end


    it "should freeze all hits" do
      subject.hits.all? { |h| h.frozen? }.should be_true
    end

    it "should freeze hits array when frozen" do
      subject.freeze
      subject.hits.should be_frozen
    end

    it { should respond_to(:to_a) }

    it "should delegate array methods" do
      subject.collect { |h| h.id }.should == response["hits"]["hits"].collect { |h| h["_id"] }
    end

  end

  context "paginated" do
    let(:response) do
      {
        "_shards"=>{"total"=>30, "successful"=>30, "failed"=>0}, 
        "hits"=>{"total"=>6, "max_score"=>1.0, "hits"=>[
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"3", "_score"=>1.0, "_source"=>{"foo" => "bar"}},
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"4", "_score"=>1.0, "_source"=>{"foo" => "baz"}}
      ]}}
    end
    
    let(:per_page) { 2 }
    let(:page) { 2 }
    
    subject { described_class.new(response, {:page => page, :per_page => per_page}) }

    its(:total_pages) { should == (response["hits"]["total"] / per_page.to_f).ceil }
    its(:next_page) { should == (page + 1) }
    its(:previous_page) { should == (page - 1) }
    its(:current_page) { should == page }
    its(:per_page) { should == per_page }
  end
end
