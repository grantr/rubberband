require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ElasticSearch::RetryingClient do

  context 'will all timeouts' do

    def new_client
      TimeoutRetryingClient.new( "http://noserverhere.local:9456", :retries => 3, :server_retry_period => nil )
    end

    describe 'when connecting' do
      it 'should give up retrying after 3 failures' do

        @client = new_client
        expect { @client.connect! }.to raise_error( ElasticSearch::TimeoutError )
        @client.connect_calls.should == 4

      end
    end

    describe 'when executing' do

      it 'should give up retrying after 3 failures' do

        @client = new_client
        expect { @client.execute( "get" ) }.to raise_error( ElasticSearch::TimeoutError )
        @client.execute_calls.should == 4

      end

    end

  end

  context 'with successful response' do

    def new_client
      CountingClient.new( "http://noserverhere.local:9456", :retries => 3, :server_retry_period => nil )
    end

    context 'when connecting' do

      it 'should try to connect only once' do

        @client = new_client
        @client.connect!

        @client.connect_calls.should == 1
      end

    end

    context 'when executing' do

      it 'should try to execute only once' do
        @client = new_client
        @client.execute('get')
        @client.execute_calls.should == 1
      end

    end

  end

  context 'with non-retryable-exception' do

    def new_client
      TimeoutRetryingClient.new( "http://noserverhere.local:9456", :retries => 3, :server_retry_period => nil, :exception => StandardError )
    end

    it 'should try to connect once and give up' do

      @client = new_client
      expect { @client.connect! }.to raise_error(StandardError)
      @client.connect_calls.should == 1

    end

    it 'should try to execute once and give up' do
      @client = new_client
      expect { @client.execute('get') }.to raise_error(StandardError)
      @client.execute_calls.should == 1
    end

  end

  context 'on next_server calls' do

    before do
      @servers = [ 'http://noserver.local1', 'http://noserver.local2' ]
    end

    def new_client( retry_period = nil )
      CountingRetryingClient.new( @servers, :server_retry_period => retry_period, :randomize_server_list => false )
    end

    it 'should pick up the next server if one is available' do
      @client = new_client

      @client.next_server.should == @servers.first
      @client.next_server.should == @servers.last
    end

    it 'should re-seed the list if client tries to pick more servers than available' do
      @client = new_client

      @client.next_server.should == @servers.first
      @client.next_server.should == @servers.last
      @client.next_server.should == @servers.first
    end

    it 'should raise a NoServersAvailable if tried to take too many servers without waiting' do

      @client = new_client 10

      @client.next_server.should == @servers.first
      @client.next_server.should == @servers.last
      expect { @client.next_server }.to raise_error(ElasticSearch::NoServersAvailable)

    end

  end

end