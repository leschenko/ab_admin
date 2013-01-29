require 'ab_admin/hooks'

if Object.const_defined?('AbAdmin')
  AbAdmin.setup do |config|
    # Flash keys
    #config.flash_keys = [ :success, :failure ]
    config.site_name = 'Dummy'
  end
end

I18n.available_locales = Globalize.available_locales = [:ru, :en]

