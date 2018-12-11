require 'ostruct'
require 'csv'

class Locator
  include Singleton
  include AbAdmin::Models::Locator
  include ::AbAdmin::Concerns::Reloadable

  has_reload_check('i18n_reload_key', Rails.logger) { I18n.reload! }

  attr_accessor :files, :data

  def self.export(*keys, locales: nil)
    return if keys.blank?
    locales ||= I18n.available_locales
    I18n.backend.available_locales # Force load translations
    filter_keys = keys.map {|k| k.include?('*') ? Regexp.new("\\A#{k.gsub('.', '\.').gsub('*', '.*')}\\z") : k}
    data = filter_keys.each_with_object(Hash.new { |h, k| h[k] = [] }) do |key, res|
      locales.each_with_index do |l, i|
        translations[l].find_all{|k, _| key.is_a?(Regexp) ? k =~ key : k == key }.each{|k, v| res[k][i] = v}
      end
    end
    for_csv = [['DO NOT EDIT THIS COLUMN!', *locales]] + data.map{|k, v| [k, *v] }
    for_csv.map(&:to_csv).join
  end

  def self.translations
    @translations ||= I18n.backend.send(:translations).slice(*I18n.available_locales).transform_values{|v| v.flatten_hash.transform_keys{|k| k.join('.') } }
  end
end