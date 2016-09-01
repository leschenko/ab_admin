require_relative 'boot'

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)
require 'ab_admin'

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
        #{config.root}/../../lib/generators/ab_admin/install/templates/models/
        #{config.root}/../../lib/generators/ab_admin/install/templates/uploaders
        #{config.root}/../../lib/generators/ab_admin/install/templates/models/ab_admin
        #{config.root}/app/models/ab_admin)

    config.paths['db/migrate'] << File.expand_path('../../../../../db/migrate', __FILE__)
    config.paths['app/helpers'] << File.expand_path('../../../../lib/generators/ab_admin/install/templates/helpers', __FILE__)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :ru
    config.i18n.default_locale = ENV['RAILS_LOCALE'] if ENV['RAILS_LOCALE']

    base_dir = File.expand_path('../../../../app/', __FILE__)
    dirs = %W(#{base_dir}/controllers/admin #{base_dir}/helpers/admin)
    config.eager_load_paths += dirs

    config.action_mailer.default_url_options = {host: 'localhost:3000'}
  end
end

