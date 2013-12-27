require 'ab_admin/hooks'

if Object.const_defined?('AbAdmin')
  AbAdmin.setup do |config|
    # Flash keys
    #config.flash_keys = [ :success, :failure ]
    config.site_name = 'Dummy'
  end
end

I18n.available_locales = Globalize.available_locales = [:ru, :en]
I18n.enforce_available_locales = false

require 'factory_girl'
FactoryGirl.definition_file_paths = [File.expand_path('../../factories/', __FILE__)]
FactoryGirl.find_definitions

if Rails.env.development?
  require 'sass'
  require 'sass/engine'

  module Sass
    class Engine
      def initialize(template, options={})
        @options = self.class.normalize_options(options)
        @options[:debug_info] = true
        @template = template
      end
    end
  end
end