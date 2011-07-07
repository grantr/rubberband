require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "connect" do

  context 'one server' do
    let(:servers) { 'http://127.0.0.1:9200' }

    it 'should connect' do
      client = ElasticSearch.new(servers)
      client.nodes_info.should include('cluster_name')
    end
  end

  context "multiple servers" do
  end
 
  context 'invalid server' do
    let(:servers) { 'http://0.1.1.1:9200' }

    it 'should raise ConnectionFailed' do
      expect { ElasticSearch.new(servers).nodes_info }.to raise_error(ElasticSearch::ConnectionFailed)
    end
  end

  context 'invalid servers' do
    let(:servers) { ['http://0.1.1.1:9200', 'http://0.2.2.2:9200'] }

    it 'should raise ConnectionFailed' do
      expect { ElasticSearch.new(servers).nodes_info }.to raise_error(ElasticSearch::ConnectionFailed)
    end
  end
end
