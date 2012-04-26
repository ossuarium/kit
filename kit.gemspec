# -*- encoding: utf-8 -*-
require File.expand_path( '../lib/kit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Evan Boyd Sosenko']
  gem.email         = ['razorx@evansosenko.com']
  gem.description   = %q{Extendable tool to manage site development and more.}
  gem.summary       = %q{Kit is a framework for making simple management tools called kits.}
  gem.homepage      = "http://evansosenko.com"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'kit'
  gem.require_paths = ['lib']
  gem.platform      = Gem::Platform::RUBY
  gem.version       = Kit::VERSION

  gem.add_dependency 'sqlite3'

  gem.add_development_dependency 'rspec'

  gem.requirements  << 'SQLite3'
end