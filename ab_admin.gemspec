# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ab_admin/version'

Gem::Specification.new do |gem|
  gem.name          = 'ab_admin'
  gem.version       = AbAdmin::VERSION
  gem.authors       = ['Alex Leschenko']
  gem.email         = %w(leschenko.al@gmail.com)
  gem.description   = %q{Simple and real-life tested Rails::Engine admin interface}
  gem.summary       = %q{Simple and real-life tested Rails::Engine admin interface based on slim, bootstrap, inherited_resources, simple_form, device, cancan}
  gem.homepage      = 'https://github.com/leschenko/ab_admin'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)
end
