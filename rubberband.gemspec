# -*- encoding: utf-8 -*-

require "./lib/elasticsearch/version"

Gem::Specification.new do |s|
  s.name = "rubberband"
  s.version = ElasticSearch::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Grant Rodgers"]
  s.email       = ["grantr@gmail.com"]
  s.homepage    = "http://github.com/grantr/rubberband"
  s.description = %q{An ElasticSearch client}

  s.rubyforge_project = "rubberband"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc",
    "TODO",
    "CONTRIBUTORS"
  ]
  s.licenses = ["MIT"]

  s.add_runtime_dependency("yajl-ruby", [">= 0"])
  s.add_runtime_dependency("escape_utils", [">= 0.2.3"])
  s.add_development_dependency("simplecov", [">= 0.3.8"])
  s.add_development_dependency("bundler", ["~> 1.0"])
  s.add_development_dependency("rspec", ["~> 2"])
  s.add_development_dependency("yard", ["~> 0.6"])
  s.add_development_dependency("mocha", ["~> 0.9.11"])
end
