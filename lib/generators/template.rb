gem 'jquery-rails'
gem 'rails-i18n'
gem 'slim'

gem 'inherited_resources', github: 'activeadmin/inherited_resources'
gem 'has_scope'
gem 'rack-pjax'

gem 'devise'
gem 'devise-encryptable'
gem 'cancancan'

gem 'protected_attributes', github: 'leschenko/protected_attributes'
gem 'galetahub-enum_field', require: 'enum_field'
gem 'ransack'
gem 'simple_slug'
gem 'awesome_nested_set'
gem 'globalize', github: 'globalize/globalize'

gem 'carrierwave'
gem 'mini_magick'
# 3.0 is broken -  creates new `configatron` instance in every namespace
gem 'configatron', '~> 2.13'
gem 'simple_form'
gem 'coffee-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'bootstrap-sass'
gem 'bootstrap-wysihtml5-rails', '~> 0.3.1.24'
gem 'select2-rails', '~> 3.5.9.3'
gem 'jquery-fileupload-rails'
gem 'fancybox2-rails'
gem 'i18n-js'

gem 'ruby-progressbar'
gem 'ruby2xlsx'
gem 'rest-client'
gem 'nested_form', '~> 0.2.2'

install_ckeditor = yes?('Install ckeditor?')
gem 'ckeditor' if install_ckeditor

gem 'ab_admin', github: 'leschenko/ab_admin', branch: 'rails-5'

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'forgery'
  gem 'byebug'
end

gem_group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'connection_pool'
  gem 'fuubar'
  gem 'guard-rspec'
  gem 'rb-fsevent', require: false
  gem 'growl', require: false
end

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

# run bundle install
run('bundle install')
#run('bundle install --path=vendor/bundle --binstubs')

# create database
rake('db:create') if yes?('Create database?')

# run default generators
generate('ckeditor:install', '--orm=active_record', '--backend=carrierwave') if install_ckeditor
generate('devise:install')
generate('simple_form:install', '--bootstrap')
generate('ab_admin:install')

# copy migrations
rake('ab_admin:install:migrations')

# init git
git(:init) if yes?('Init empty git?')

# create && migrate database
rake('db:migrate') if yes?('Run db:migrate?')

# run db seed
rake('db:seed') if yes?('Run db:seed?')

# copy ckeditor assets to public/javascripts
generate('ab_admin:ckeditor_assets') if install_ckeditor

# run db seed
rake('i18n:js:export') if yes?('Export i18n js locales?')