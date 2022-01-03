require_relative 'boot'

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)
require 'ab_admin'

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults '7.0'

    # Custom directories with classes and modules you want to be autoloadable.
    base_dir = File.expand_path('../../../..', __FILE__)
    config.autoload_paths += %W(#{base_dir}/lib/generators/ab_admin/install/templates/models #{base_dir}/lib/generators/ab_admin/install/templates/uploaders)

    config.paths['db/migrate'] << "#{base_dir}/db/migrate"
    config.paths['app/helpers'] << "#{base_dir}/lib/generators/ab_admin/install/templates/helpers"
    config.paths['app/models'] << "#{base_dir}/lib/generators/ab_admin/install/templates/models"
    config.paths['app/models'] << "#{base_dir}/lib/generators/ab_admin/install/templates/models/ab_admin"

    config.eager_load_paths += %W(#{config.root}/app/models/ab_admin #{base_dir}/app/controllers #{base_dir}/app/helpers #{base_dir}/lib/generators/ab_admin/install/templates/uploaders)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = ENV['RAILS_LOCALE'] if ENV['RAILS_LOCALE']
    config.i18n.available_locales = [:en, :de]

    config.action_mailer.default_url_options = {host: 'localhost:3000'}
    config.active_record.belongs_to_required_by_default = false
  end
end

