gem 'rails-i18n'
gem 'slim'

gem 'inherited_resources'
gem 'has_scope'
gem 'rack-pjax'
#gem 'ransack', github: 'activerecord-hackery/ransack', branch: 'rails-4.1'
#gem 'polyamorous', github: 'activerecord-hackery/polyamorous', branch: 'rails-4.1'

gem 'devise'
gem 'devise-encryptable'
gem 'cancan', github: 'ryanb/cancan'

gem 'protected_attributes'
gem 'galetahub-enum_field', require: 'enum_field'
gem 'ransack'
gem 'simple_slug'
gem 'awesome_nested_set'
gem 'globalize', '~> 4.0.0'

gem 'carrierwave'
gem 'mini_magick'
gem 'configatron', '~> 2.13'
gem 'simple_form'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'bootstrap-sass'
gem 'bootstrap-wysihtml5-rails'
gem 'select2-rails'
gem 'jquery-fileupload-rails'
gem 'fancybox2-rails'
gem 'i18n-js'

gem 'ruby-progressbar'
gem 'ruby2xlsx'
gem 'rest-client'
gem 'russian'
gem 'nested_form', '~> 0.2.2'
gem 'puma', require: false

gem 'ab_admin', github: 'leschenko/ab_admin', branch: 'rails4'

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
  gem 'activevalidators', '~> 1.9.0'

  gem_group :development, :test do
    gem 'quiet_assets'
    gem 'rspec-rails'
    gem 'factory_girl_rails'
    gem 'forgery'
  end

  gem_group :development do
    gem 'slim-rails'
    gem 'annotate'
    gem 'letter_opener'
    gem 'better_errors'
    gem 'binding_of_caller'
  end

  gem_group :test do
    gem 'database_cleaner'
    gem 'fuubar'
    gem 'guard-rspec'
  end
end

# run bundle install
run('bundle install')
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
if yes?('Export i18n js locales?')
  rake('i18n:js:export')
end