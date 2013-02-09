require 'configatron'

class Settings
  include Singleton
  extend ActiveModel::Naming
  include AbAdmin::Models::Settings

  attr_accessor :paths, :data

end
