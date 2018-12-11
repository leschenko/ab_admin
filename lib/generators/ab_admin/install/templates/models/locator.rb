require 'ostruct'

class Locator
  include Singleton
  include AbAdmin::Models::Locator
  include ::AbAdmin::Concerns::Reloadable

  has_reload_check('i18n_reload_key', Rails.logger) { I18n.reload! }

  attr_accessor :files, :data
end