ENV['RAILS_ENV'] = 'test'
require 'capybara/rails'
require 'database_cleaner'
require 'capybara/dsl'
require 'active_support/all'
require 'action_controller'

include Capybara::DSL
Capybara.default_driver = :selenium
DatabaseCleaner.strategy = :truncation
Capybara.app_host = 'http://localhost:3000'

include Warden::Test::Helpers
Warden.test_mode!

require 'factory_bot'
FactoryBot.definition_file_paths = [File.expand_path('../factories/', __FILE__)]
FactoryBot.find_definitions
Dir[File.join(Rails.root.join('../factories'), '*.rb')].each { |f| load f }

def login_as_admin
  user = {email: 'test@example.com', password: '123456'}
  @me = User.find_by_email('test@example.com') || FactoryBot.create(:admin_user, user)
  visit '/users/sign_in'
  fill_in 'Email', with: user[:email]
  fill_in 'Password', with: user[:password]
  click_button 'Sign in'
  #login_as(@me)
end

def build_structures
  [{'title' => 'node-1', 'parent_name' => ''},
  {'title' => 'node-1-1', 'parent_name' => 'node-1'},
  {'title' => 'node-1-2', 'parent_name' => 'node-1'},
  {'title' => 'node-2', 'parent_name' => ''},
  {'title' => 'node-2-1', 'parent_name' => 'node-2'},
  {'title' => 'node-2-1-1', 'parent_name' => 'node-2-1'}].each do |attrs|
    parent = Structure.joins(:translations).where("structure_translations.title='#{attrs['parent_name']}'").first
    FactoryBot.create(:structure_page, title: attrs['title'], parent: parent)
  end
  visit '/admin/structures'
end
