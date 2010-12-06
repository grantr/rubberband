require 'test_helper'

class HitsTest < Test::Unit::TestCase
  context "A Hit instance" do
    setup do
      @response = {"_source" => {"foo" => "bar"}, "_id" => "1"}
      @hit = ElasticSearch::Api::Hit.new(@response)
    end

    should "set id" do
      assert_equal @response["_id"], @hit.id
    end

    should "set hit attributes" do
      assert_equal @response["_source"]["foo"], @hit.foo
    end

    should "be frozen" do
      assert @hit.attributes.frozen?
    end

  end

  context "A Hits instance" do
    setup do
      @response = {
        "_shards"=>{"total"=>30, "successful"=>30, "failed"=>0}, 
        "hits"=>{"total"=>2, "max_score"=>1.0, "hits"=>[
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"1", "_score"=>1.0, "_source"=>{"foo" => "bar"}},
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"2", "_score"=>1.0, "_source"=>{"foo" => "baz"}}
      ]}}
      @hits = ElasticSearch::Api::Hits.new(@response)
    end

    should "set response" do
      assert_equal @response, @hits.response
    end

    should "set total_entries" do
      assert_equal @response["hits"]["hits"].size, @hits.total_entries
    end

    should "instantiate hits in order" do
      @response["hits"]["hits"].each_with_index do |hit, i|
        assert_equal ElasticSearch::Api::Hit.new(hit), @hits.hits[i]
      end
    end

    should "freeze hits" do
      assert @hits.hits.all? { |h| h.frozen? }
    end

    should "freeze hits array when frozen" do
      @hits.freeze
      assert @hits.hits.frozen?
    end

    should "respond to to_a" do
      assert_equal @hits.hits, @hits.to_a
    end

    should "respond to array methods" do
      assert @hits.respond_to?(:collect)
      assert_equal @response["hits"]["hits"].collect { |h| h["_id"] }, @hits.collect { |h| h.id }
    end
  end

  context "a paginated hits instance" do
    setup do
      @response = {
        "_shards"=>{"total"=>30, "successful"=>30, "failed"=>0}, 
        "hits"=>{"total"=>6, "max_score"=>1.0, "hits"=>[
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"3", "_score"=>1.0, "_source"=>{"foo" => "bar"}},
          {"_index"=>"test_index", "_type"=>"test_type", "_id"=>"4", "_score"=>1.0, "_source"=>{"foo" => "baz"}}
      ]}}
      @per_page = 2
      @page = 2
      @hits = ElasticSearch::Api::Hits.new(@response, {:page => @page, :per_page => @per_page})
    end

    should "respond to total_pages" do
      assert_equal (@response["hits"]["total"] / @per_page.to_f).ceil, @hits.total_pages
    end

    should "respond to next_page" do
      assert_equal @page + 1, @hits.next_page
    end

    should "respond to previous_page" do
      assert_equal @page - 1, @hits.previous_page
    end

    should "respond to current_page" do
      assert_equal @page, @hits.current_page
    end

    should "respond to per page" do
      assert_equal @per_page, @hits.per_page
    end
  end
end
