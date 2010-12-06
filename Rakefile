require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/elasticsearch/version'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubberband"
  gem.version = ElasticSearch::Version::STRING
  gem.homepage = "http://github.com/grantr/rubberband"
  gem.license = "Apache v2.0"
  gem.summary = %Q{An ElasticSearch client.}
  gem.description = %Q{An ElasticSearch client with ThriftClient-like failover handling.}
  gem.email = "grantr@gmail.com"
  gem.authors = ["grantr"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = ElasticSearch::Version::STRING
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubberband #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
