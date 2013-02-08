require 'ya2yaml'
require 'ostruct'

class Locator
  extend ActiveModel::Naming
  include Singleton

  Kernel.suppress_warnings do
    Ya2YAML::REX_BOOL = /y|Y|Yes|YES|n|N|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF/ if defined? Ya2YAML
  end

  attr_accessor :files, :data

  def initialize
    @data = {}
    @files = self.class.find_files
  end

  def all
    @paths.each { |path| @data.deep_merge!(YAML.load_file(path)) }
    @data
  end

  def self.find_files
    Dir[Rails.root.join('config', 'locales', '*.yml')]
  end

  def self.save(path, data)
    File.open(path, 'w') do |file|
      file.write data.ya2yaml.gsub(/^(\s+)(yes|no):/, '\1"\2":')
    end
  end

  def self.prepare_data(path)
    data = YAML.load_file(path)
    locale = data.keys.first
    OpenStruct.new({:locale => locale.to_sym, :data => data[locale], :flat_data => flat_hash(data[locale]),
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
        next if locale == I18n.default_locale
        clean_locale_hash = main_file.data.deep_clear_values
        path = File.join(main_file.dir, main_file.filename.sub(locale_replace_regexp, locale.to_s))
        if File.exists?(path)
          file = self.class.prepare_data(path)
          self.class.save(path, {locale.to_s => clean_locale_hash.deep_add(file.data)})
        else
          self.class.save(path, {locale.to_s => clean_locale_hash})
          message = 'Reload application to pick up new locale files'
        end
      end
    end
    {:message => message}
  end

end