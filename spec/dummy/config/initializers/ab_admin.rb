require 'ab_admin/hooks'
require 'enum_field'

if Object.const_defined?('AbAdmin')
  AbAdmin.setup do |config|
    # Flash keys
    #config.flash_keys = [ :success, :failure ]
  end
end


