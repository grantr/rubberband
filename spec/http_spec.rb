require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ElasticSearch::Transport::HTTP do

  context "no uri scheme" do
    let(:server) { '127.0.0.1:9200' }
    it 'should prepend the default scheme' do
      described_class.new(server).instance_variable_get('@server').should =~ /^http:\/\//
    end

    it 'should make default protocol configurable' do
      described_class.new(server, :protocol => 'https').instance_variable_get('@server').should =~ /^https:\/\//
    end
  end

  context 'with block' do
    let(:server) { 'http://127.0.0.1:9200' }

    it 'should pass the block to Faraday.new' do
      transport = described_class.new(server) do |conn|
        conn.options[:foo] = 'bar'
      end
      transport.connect!

      transport.session.options[:foo].should == 'bar'
    end
  end
end
