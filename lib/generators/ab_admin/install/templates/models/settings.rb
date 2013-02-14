require 'configatron'

class Settings
  include Singleton
  include AbAdmin::Models::Settings

  attr_accessor :paths, :data

end
