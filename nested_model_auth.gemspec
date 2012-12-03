# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nested_model_auth/version'

Gem::Specification.new do |gem|
  gem.name          = "nested_model_auth"
  gem.version       = NestedModelAuth::VERSION
  gem.authors       = ["John Cant"]
  gem.email         = ["a.johncant@gmail.com"]
  gem.description   = %q{model based authorization for new or edited records}
  gem.summary       = %q{Protect your mass assignment by explicit authorization}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
