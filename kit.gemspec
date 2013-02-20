# -*- encoding: utf-8 -*-
require File.expand_path( '../lib/kit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Evan Boyd Sosenko']
  gem.email         = ['razorx@evansosenko.com']
  gem.description   = %q{Kit is a framework for making simple management tools called kits.}
  gem.summary       = %q{Write your shell scripts in beautiful Ruby, put them in a kit, and keep them DRY.}
  gem.homepage      = "http://evansosenko.com"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'kit'
  gem.require_paths = ['lib']
  gem.platform      = Gem::Platform::RUBY
  gem.version       = Kit::VERSION

  gem.add_dependency 'activerecord'
  gem.add_dependency 'rake'

  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'git'

end
