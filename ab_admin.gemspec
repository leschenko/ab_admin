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

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'rails-i18n'
  s.add_dependency 'slim'
  s.add_dependency 'inherited_resources', '~> 1.6'
  s.add_dependency 'rack-pjax'
  s.add_dependency 'ransack'
  s.add_dependency 'has_scope'
  s.add_dependency 'simple_slug'
  s.add_dependency 'devise', '~> 4'
  s.add_dependency 'cancancan', '~> 1.7'
  s.add_dependency 'galetahub-enum_field'
  s.add_dependency 'awesome_nested_set', '~> 3.0.1'

  s.add_dependency 'carrierwave'
  s.add_dependency 'mini_magick'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'sass-rails'

  s.add_dependency 'bootstrap-sass', '~> 2.3.2.2'
  s.add_dependency 'bootstrap-wysihtml5-rails', '~> 0.3.1.24'
  s.add_dependency 'will_paginate'
  s.add_dependency 'will_paginate-bootstrap', '~> 0.2.5'
  s.add_dependency 'nested_form', '~> 0.2.2'
  s.add_dependency 'simple_form'
  s.add_dependency 'i18n-js'
  s.add_dependency 'ruby-progressbar'

  s.add_development_dependency 'mysql2', '~> 0.3.19'
end
