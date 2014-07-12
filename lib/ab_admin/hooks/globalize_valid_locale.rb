# add `valid_locale?` method to validate locale with globalize
module Globalize
  mattr_accessor :available_locales

  def self.valid_locale?(loc)
    return false unless loc
    available_locales.include?(loc.to_sym)
  end
end