# init gems list
gem 'slim'
gem 'rails-i18n'

gem 'devise'
gem 'devise-encryptable'
gem 'cancan', '~> 1.6.7'

gem 'ransack'
gem 'awesome_nested_set'
gem 'galetahub-enum_field', '~> 0.2.0', require: 'enum_field'
gem 'friendly_id'

gem 'configatron'
gem 'inherited_resources', '~> 1.4.0'
gem 'carrierwave'
gem 'mini_magick'
gem 'ya2yaml'
gem 'multi_json'
gem 'ruby-progressbar'

gem 'rack-pjax'
gem 'simple_form'
gem 'bootstrap-sass', '2.0.4'
gem 'will_paginate', '>= 3.0.3'
gem 'bootstrap-wysihtml5-rails'
gem 'will_paginate-bootstrap', '0.2.1'
gem 'select2-rails'
gem 'gon'
gem 'i18n-js'

gem 'globalize3', github: 'globalize/globalize', ref: '6ad3de9f257a'
gem 'sunrise-file-upload', github: 'leschenko/sunrise-file-upload', branch: 'master', ref: '6aad0cf'
gem 'turbo-sprockets-rails3', group: :assets
gem 'ab_admin', github: 'leschenko/ab_admin', ref: 'ab57386'

ckeditor = yes?('Install ckeditor?')

if ckeditor
  gem 'ckeditor'
end

gem_adds = yes?('Add additional gems (mostly dev and testing tools)?')

if gem_adds
  # non dependency gems
  gem 'dalli'
  gem 'exception_notification'
  gem 'redis-actionpack'
  gem 'ruby2xlsx'
  gem 'cache_digests'
  gem 'russian'
  gem 'activevalidators', '~> 1.9.0'
  gem 'nested_form', '0.2.2'
  gem 'has_scope'
  gem 'squeel'
  gem 'fancybox2-rails'
  gem 'rest-client'

  gem_group :development, :test do
    gem 'rspec-rails'
    gem 'cucumber-rails', require: false

    gem 'factory_girl_rails'
    gem 'quiet_assets'
    gem 'forgery'

    gem 'guard-rspec'
    gem 'guard-spork'
    gem 'guard-cucumber'
    gem 'rb-fsevent', require: false
    gem 'growl'
  end

  gem_group :development do
    gem 'pry-rails'
    gem 'pry-doc'
    gem 'slim-rails'
    gem 'thin', require: false
    gem 'annotate'
    gem 'letter_opener'
    gem 'better_errors'
    gem 'binding_of_caller'
  end

  gem_group :test do
    gem 'spork', '1.0.0rc4'
    gem 'database_cleaner'
    gem 'shoulda-matchers'
    gem 'fuubar'
    gem 'capybara'
    gem 'connection_pool'
  end

  gem_group :staging, :production do
    gem 'unicorn', require: false
  end
end

# run bundle install
run('bundle install --binstubs')
#run('bundle install --path=vendor/bundle --binstubs')

# create database
if yes?('Create database?')
  rake('db:create')
end

# run default generators
if ckeditor
  generate('ckeditor:install', '--orm=active_record', '--backend=carrierwave')
end
generate('devise:install')
generate('simple_form:install', '--bootstrap')
generate('ab_admin:install')

# copy migrations
rake('ab_admin:install:migrations')

# init git
if yes?('Init empty git?')
  git(:init)
end

# create && migrate database
if yes?('Run db:migrate?')
  rake('db:migrate')
end

# run db seed
if yes?('Run db:seed?')
  rake('db:seed')
end

# copy ckeditor assets to public/javascripts
if ckeditor
  generate('ab_admin:ckeditor_assets')
end

# run db seed
if gem_adds && yes?('Export i18n js locales?')
  rake('i18n:js:export')
end

remove_file 'public/index.html'


