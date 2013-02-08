require 'ya2yaml'

class Locator
  extend ActiveModel::Naming
  include Singleton

  attr_accessor :files, :data

  def initialize
    @data = {}
    @files = Dir[Rails.root.join('config', 'locales', '*.yml')]
  end

  def all
    @paths.each do |path|
      @data.deep_merge!(YAML.load_file(path))
    end
    @data
  end

  def self.save(path, data)
    File.open(path, 'w') do |file|
      file.write data.ya2yaml
    end
  end

  def self.prepare_data(path)
    data = YAML.load_file(path)
    locale = data.keys.first
    {:locale => locale, :data => flat_hash(data[locale]), :filename => File.basename(path)}
  end

  def self.flat_hash(hash, k = [])
    return {k => hash} unless hash.is_a?(Hash)
    hash.inject({}) { |h, v| h.merge! flat_hash(v[-1], k + [v[0]]) }
  end

end