SPEC_PATH = File.expand_path('../../../spec', __FILE__)
ENV['RAILS_ROOT'] = File.expand_path('../../../spec/dummy', __FILE__)

require 'cucumber/rails'

Capybara.default_selector = :css

ActionController::Base.allow_rescue = false

require 'database_cleaner'
require 'database_cleaner/cucumber'
DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :transaction
Cucumber::Rails::World.use_transactional_fixtures = false

require 'factory_girl'
FactoryGirl.definition_file_paths = [File.join(SPEC_PATH, 'factories')]
FactoryGirl.find_definitions

Capybara.default_wait_time = 5
BCrypt::Engine::DEFAULT_COST = 1

require File.join(SPEC_PATH, 'support/shared_connection')

include Warden::Test::Helpers
Warden.test_mode!
DatabaseCleaner.clean_with(:truncation)

After do
  Warden.test_reset!
  AbAdmin.test_settings = {}
end

Before '@locator' do
  FileUtils.cp_r Rails.root.join('config', 'locales'), Rails.root.join('tmp')
end

Before '@fancy_select' do
  AbAdmin.test_settings[:enable_fancy_select] = true
end

After '@locator' do
  FileUtils.rm_rf Rails.root.join('config', 'locales')
  FileUtils.cp_r Rails.root.join('tmp/locales'), Rails.root.join('config')
end
