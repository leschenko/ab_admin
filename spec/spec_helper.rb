# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'generator_spec/test_case'
require 'capybara/rspec'


require 'factory_girl'
FactoryGirl.definition_file_paths = [File.expand_path('../factories/', __FILE__)]
FactoryGirl.find_definitions

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'example.com'

Rails.backtrace_cleaner.remove_silencers!

require 'carrierwave'
CarrierWave.configure do |config|
  config.storage = :file
  config.enable_processing = false
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.include AbAdmin::Engine.routes.url_helpers
  config.include Warden::Test::Helpers

  config.mock_with :rspec

  config.extend ControllerMacros, :type => :controller
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
  config.include MailerMacros
  config.before(:each) { reset_email }

end

