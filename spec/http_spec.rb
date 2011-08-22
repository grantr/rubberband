require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ElasticSearch::Transport::HTTP do

  context "no uri scheme" do
    let(:server) { '127.0.0.1:9200' }
    it 'should prepend the default scheme' do
      described_class.new(server).instance_variable_get('@server').should =~ /^http:\/\//
    end
  end
end
