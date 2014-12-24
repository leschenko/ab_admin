# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'active_record'
require 'rspec/rails'
require 'database_cleaner'
require 'generator_spec/test_case'
require 'capybara/rspec'
require 'connection_pool'
require 'shoulda/matchers'

require 'factory_girl'
FactoryGirl.definition_file_paths = [File.expand_path('../factories/', __FILE__)]
FactoryGirl.find_definitions

require 'carrierwave'
CarrierWave.configure do |config|
  config.storage = :file
  config.enable_processing = false
end

#Rails.application.config.paths['db/migrate'].each { |migrate_path| ActiveRecord::Migrator.migrate migrate_path }

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'example.com'

Rails.backtrace_cleaner.remove_silencers!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/shared_behaviors/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = [:expect, :should]
  end

  config.include RSpec::Matchers
  config.include AbAdmin::Engine.routes.url_helpers
  config.include Warden::Test::Helpers

  config.extend ControllerMacros, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include MailerMacros
  config.before(:each) { reset_email }

  config.use_transactional_fixtures = false
  #config.backtrace_clean_patterns = []

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/uploads/[^.]*"])
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end