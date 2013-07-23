require 'ab_admin/hooks'

if Object.const_defined?('AbAdmin')
  AbAdmin.setup do |config|
    # Flash keys
    #config.flash_keys = [ :success, :failure ]
    config.site_name = 'Dummy'
  end
end

I18n.available_locales = Globalize.available_locales = [:ru, :en]

require 'factory_girl'
FactoryGirl.definition_file_paths = [File.expand_path('../../factories/', __FILE__)]
FactoryGirl.find_definitions

if Rails.env.development?
  ActiveRecord::Migrator.migrate File.expand_path('../../db/migrate/', Rails.root)
end
