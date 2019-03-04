class Settings
  include Singleton
  include AbAdmin::Models::Settings
  include ::AbAdmin::Concerns::Reloadable

  has_reload_check('settings_reload_key', Rails.logger) { Settings.load_config }

end
