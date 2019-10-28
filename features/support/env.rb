SPEC_PATH = File.expand_path('../../../spec', __FILE__)
ENV['RAILS_ROOT'] = File.expand_path('../../../spec/dummy', __FILE__)

require 'rack/handler/puma'
require 'cucumber/rails'

Capybara.default_selector = :css

ActionController::Base.allow_rescue = false

require 'database_cleaner'
require 'database_cleaner/cucumber'
DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :transaction
Cucumber::Rails::World.use_transactional_tests = false

require 'factory_bot'
FactoryBot.definition_file_paths = [File.join(SPEC_PATH, 'factories')]
FactoryBot.find_definitions

Capybara.register_server :rails_puma_custom do |app, port, host|
  Rack::Handler::Puma.run(app, Port: port, Threads: '0:1', Silent: true)
end

Capybara.configure do |config|
  config.default_selector = :css
  config.default_max_wait_time = 5
  config.ignore_hidden_elements = false
  config.visible_text_only = true
  config.server = :rails_puma_custom
end

RSpec::Expectations.configuration.on_potential_false_positives = :nothing
# BCrypt::Engine::DEFAULT_COST = 1

require File.join(SPEC_PATH, 'support/shared_connection')

include Warden::Test::Helpers
Warden.test_mode!
DatabaseCleaner.clean_with(:truncation)

After do
  Warden.test_reset!
  AbAdmin.test_settings = {}
end

Before '@fancy_select' do
  AbAdmin.test_settings[:enable_fancy_select] = true
end

Before '@javascript' do
  Capybara.page.driver.browser.manage.window.maximize
end

Before '@locator' do
  FileUtils.cp_r Rails.root.join('config', 'locales'), Rails.root.join('tmp')
end

After '@locator' do
  FileUtils.rm_rf Rails.root.join('config', 'locales')
  FileUtils.cp_r Rails.root.join('tmp/locales'), Rails.root.join('config')
end
