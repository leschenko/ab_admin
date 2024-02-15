$:.push File.expand_path('../lib', __FILE__)

require 'ab_admin/version'

Gem::Specification.new do |s|
  s.name          = 'ab_admin'
  s.version       = AbAdmin::VERSION
  s.authors       = ['Alex Leschenko']
  s.email         = %w(leschenko.al@gmail.com)
  s.description   = %q{Simple and real-life tested Rails::Engine admin interface}
  s.summary       = %q{Simple and real-life tested Rails::Engine admin interface based on slim, bootstrap, inherited_resources, simple_form, device, cancan}
  s.homepage      = 'https://github.com/leschenko/ab_admin'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 7.1.3'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'rails-i18n'
  s.add_dependency 'slim'
  s.add_dependency 'inherited_resources'
  s.add_dependency 'rack-pjax'
  s.add_dependency 'ransack'
  s.add_dependency 'simple_slug'
  s.add_dependency 'devise'
  s.add_dependency 'cancancan'
  s.add_dependency 'cancan-inherited_resources'
  s.add_dependency 'galetahub-enum_field', '~> 0.4.0'
  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'mime-types'

  s.add_dependency 'carrierwave'
  s.add_dependency 'mini_magick'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'sass-rails'

  s.add_dependency 'bootstrap-wysihtml5-rails', '~> 0.3.1.24'
  s.add_dependency 'will_paginate'
  s.add_dependency 'nested_form', '~> 0.2.2'
  s.add_dependency 'simple_form'
  s.add_dependency 'i18n-js'
  s.add_dependency 'ruby-progressbar'

  s.add_development_dependency 'mysql2'
end
