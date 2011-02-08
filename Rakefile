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

  gem.add_runtime_dependency 'patron'
  gem.add_runtime_dependency 'yajl-ruby'
  gem.add_development_dependency 'rspec', '~> 2.4'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
