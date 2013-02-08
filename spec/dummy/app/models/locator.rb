require 'ya2yaml'
require 'ostruct'

class Locator
  extend ActiveModel::Naming
  include Singleton

  attr_accessor :files, :data

  def initialize
    @data = {}
    @files = Dir[Rails.root.join('config', 'locales', '*.yml')]
  end

  def all
    @paths.each { |path| @data.deep_merge!(YAML.load_file(path)) }
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
    OpenStruct.new({:locale => locale.to_sym, :data => flat_hash(data[locale]),
                    :filename => File.basename(path), :path => path, :dir => File.dirname(path)})
  end

  def self.flat_hash(hash, k = [])
    return {k => hash} unless hash.is_a?(Hash)
    hash.inject({}) { |h, v| h.merge! flat_hash(v[-1], k + [v[0]]) }
  end

  def prepare_files
    message = nil
    locale_replace_regexp = Regexp.new("(^#{I18n.default_locale}|(?<=\.)#{I18n.default_locale}(?=\.yml))")

    locale_files = @files.map{|path| self.class.prepare_data(path) }
    main_locale_files = locale_files.find_all{|file| file.locale == I18n.default_locale }

    main_locale_files.each do |main_file|
      I18n.available_locales.each do |locale|
        clean_locale_hash = main_file.data.deep_clear_values
        path = File.join(main_file.dir, main_file.filename.sub(locale_replace_regexp, locale))
        if File.exists?(path)
          file = self.class.prepare_data(path)
          self.class.save(path, clean_locale_hash.deep_add(file.data))
        else
          self.class.save(path, clean_locale_hash)
          message = 'Reload application to pick up new locale files'
        end
      end
    end
    {:message => message}
  end

end