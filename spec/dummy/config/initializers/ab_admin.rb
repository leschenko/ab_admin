require 'ab_admin/hooks'

AbAdmin.setup do |config|
  # Flash keys
  #config.flash_keys = [ :success, :failure ]
  config.site_name = 'Dummy'
end

I18n.available_locales = AbAdmin.translated_locales = [:en, :it, :de]
I18n.enforce_available_locales = false

require 'factory_bot'
FactoryBot.definition_file_paths = [File.expand_path('../../factories/', __FILE__)]
FactoryBot.find_definitions

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
