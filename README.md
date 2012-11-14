# RubberBand
[![Build Status](https://secure.travis-ci.org/grantr/rubberband.png?branch=master)](http://travis-ci.org/grantr/rubberband) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/grantr/rubberband)

An ElasticSearch client with ThriftClient-like failover handling.

## License

Copyright 2010-2012 Grant Rodgers. See included LICENSE file.

## Features

* Automatic failover, retry, and peer discovery
* Support for multiple transports (HTTP, Thrift, Memcached)
* Support for multiple encodings (JSON, Smile TODO)

Rubberband uses MultiJson for JSON encoding and decoding and supports all JSON backends that MultiJson supports.

The HTTP transport uses Faraday, which also supports a number of http backends. Choose the one that works best for you.

## Supported Rubies

Tested on 1.8.7, 1.9.2, 1.9.3, and Rubinius in 1.8 and 1.9 mode. Ruby 1.8.6 is NOT supported due to missing String#bytesize.

## Usage

Instantiate a client:

    client = ElasticSearch.new('http://127.0.0.1:9200', :index => "twitter", :type => "tweet")

Instantiate a client with multiple servers:
  
    client = ElasticSearch.new(['127.0.0.1:9200', '127.0.0.1:9201'])

Instantiate a client using a Heroku URL (this sets the default index):

    client = ElasticSearch.new(ENV['ELASTICSEARCH_URL'])

Connect using the thrift transport (requires the thrift gem and elasticsearch thrift plugin to be installed):

    client = ElasticSearch.new('127.0.0.1:9500', :transport => ElasticSearch::Transport::Thrift)

Pass a block to Faraday to configure middleware and options:

```ruby
  client = ElasticSearch::Client.new('127.0.0.1:9200') do |conn|
    conn.response :logger
    conn.adapter Faraday.default_adapter
  end
```

API:
```ruby
  client.default_index = "test_index"
  client.default_type  = "test_type"
  client.index({:body => "elasticsearch is cool"}, :id => 1)  
  client.get("1")  
  client.search("body:elasticsearch")  
```
## TODO

See TODO file.

## Contributing

http://github.com/grantr/rubberband

Fork, code, send pull request
