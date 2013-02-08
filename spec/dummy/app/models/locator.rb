class Locator
  extend ActiveModel::Naming
  include Singleton

  attr_accessor :files, :data

  LOCALE_REGEXP = Regexp.new(I18n.available_locales.join('|'))

  def initialize
    @data = {}
    @files = find_files
  end

  def find_files
    path = Rails.root.join('config', 'locales')
    Dir["#{path}/*.yml"]
  end

  def all
    @paths.each do |path|
      @data.deep_merge!(YAML.load_file(path))
    end
    @data
  end

  def self.prepare_data(path)
    data = YAML.load_file(path)
    locale = data.keys.first
    {:locale => locale, :data => flat_hash(data[locale])}
  end

  def self.flat_hash(hash, k = [])
    return {k => hash} unless hash.is_a?(Hash)
    hash.inject({}) { |h, v| h.merge! flat_hash(v[-1], k + [v[0]]) }
  end

end