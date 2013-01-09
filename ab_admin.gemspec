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

  gem.add_dependency 'rails', '~> 3.2'
  gem.add_dependency 'rails-i18n'
  gem.add_dependency 'slim'
  gem.add_dependency 'devise', '~> 2.1.0'
  gem.add_dependency 'cancan'
  gem.add_dependency 'inherited_resources', '~> 1.3.0'
  gem.add_dependency 'rack-pjax'
  gem.add_dependency 'ransack'
  gem.add_dependency 'has_scope'
  gem.add_dependency 'friendly_id'
  gem.add_dependency 'galetahub-enum_field'
  gem.add_dependency 'carrierwave'
  gem.add_dependency 'mini_magick'
  gem.add_dependency 'jquery-rails'
  gem.add_dependency 'coffee-rails'
  gem.add_dependency 'sass-rails'

  gem.add_dependency 'bootstrap-sass', '2.0.4'
  gem.add_dependency 'bootstrap-wysihtml5-rails'
  gem.add_dependency 'will_paginate', '>= 3.0.3'
  gem.add_dependency 'will_paginate-bootstrap'
  gem.add_dependency 'nested_form', '0.2.2'
  gem.add_dependency 'simple_form'
  gem.add_dependency 'russian'
  gem.add_dependency 'gon'
  gem.add_dependency 'i18n-js'
  gem.add_dependency 'ruby-progressbar'

  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'factory_girl_rails'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'fuubar', '1.1.0'
  gem.add_development_dependency 'generator_spec'
  gem.add_development_dependency 'capybara'
  gem.add_development_dependency 'connection_pool'
  gem.add_development_dependency 'rack_session_access'
end
