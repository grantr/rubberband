require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "connect" do
  context 'ip and port only' do
    let(:servers) { '127.0.0.1:9200' }

    it 'should connect' do
      client = ElasticSearch.new(servers)
      client.nodes_info.should include('cluster_name')
    end
  end

  context 'one server' do
    let(:servers) { 'http://127.0.0.1:9200' }

    it 'should connect' do
      client = ElasticSearch.new(servers)
      client.nodes_info.should include('cluster_name')
    end

  end

  context "multiple servers" do
    let(:servers) { ['http://127.0.0.1:9200', 'http://127.0.0.1:9201'] }

    it 'should set servers array' do
      client = ElasticSearch.new(servers, :auto_discovery => false)
      client.servers.should == servers
    end

    it 'should choose a server to connect to' do
      client = ElasticSearch.new(servers, :auto_discovery => false)
      servers.should include(client.current_server)
    end
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

  context 'server url with index' do
    let(:servers) { 'http://127.0.0.1:9200/test_index' }

    it 'should set default_index' do
      client = ElasticSearch.new(servers, :auto_discovery => false)
      client.current_server.should == 'http://127.0.0.1:9200'
      client.default_index.should == 'test_index'
    end

    it 'should set default_type' do
      client = ElasticSearch.new(servers + "/test_type", :auto_discovery => false)
      client.current_server.should == 'http://127.0.0.1:9200'
      client.default_index.should == 'test_index'
      client.default_type.should == 'test_type'
    end
  end

  context 'alternate transport' do
    let(:servers) { '127.0.0.1:9500' }

    it 'should take an alternate transport class' do
      client = ElasticSearch.new(servers, :auto_discovery => false, :transport => ElasticSearch::Transport::Thrift)
      client.connect!
      client.connection.should be_an_instance_of(ElasticSearch::Transport::Thrift)
    end

    it 'should take a transport object' do
      transport = ElasticSearch::Transport::Thrift.new(servers)
      client = ElasticSearch.new(servers, :auto_discovery => false, :transport => transport)
      client.connect!
      client.connection.should be(transport)
    end
  end
end
