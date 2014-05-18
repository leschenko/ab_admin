source 'https://rubygems.org'

gemspec

gem 'jquery-rails'
gem 'rails-i18n'
gem 'slim'

gem 'inherited_resources'
gem 'has_scope'
gem 'rack-pjax'
#gem 'ransack', github: 'activerecord-hackery/ransack', branch: 'rails-4.1'
#gem 'polyamorous', github: 'activerecord-hackery/polyamorous', branch: 'rails-4.1'

gem 'devise'
gem 'devise-encryptable'
gem 'cancancan', '~> 1.7'

gem 'protected_attributes'
gem 'galetahub-enum_field', require: 'enum_field'
gem 'ransack'
gem 'simple_slug', github: 'leschenko/simple_slug', ref: 'b9b17a3'
gem 'awesome_nested_set'
gem 'globalize', '~> 4.0.0'

gem 'carrierwave'
gem 'mini_magick'
# 3.0 is broken -  creates new `configatron` instance in every namespace
gem 'configatron', '~> 2.13'
gem 'simple_form', '~> 3.0.2'
gem 'coffee-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'bootstrap-sass'
gem 'bootstrap-wysihtml5-rails'
gem 'select2-rails'
gem 'jquery-fileupload-rails'
gem 'fancybox2-rails'
gem 'i18n-js'

gem 'ruby-progressbar'
gem 'quiet_assets'
gem 'ruby2xlsx'
gem 'rest-client'
gem 'russian'
gem 'nested_form', '~> 0.2.2'
gem 'ckeditor'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'forgery'
  gem 'debugger'
end

group :test do
  gem 'childprocess', '0.3.6'
  gem 'cucumber-rails', require: false
  gem 'capybara', '~> 2.2.0'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'connection_pool'
  gem 'fuubar'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-fsevent', require: false
  gem 'growl', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :production do
  gem 'puma'
end