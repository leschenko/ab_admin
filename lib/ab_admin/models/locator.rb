require 'csv'

module AbAdmin
  module Models
    module Locator
      YAML_LINE_WIDTH = 200
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Naming
        extend ActiveRecord::Translation
        class_attribute :base_class
        self.base_class = self
      end

      module ClassMethods
        def find_files
          Dir[Rails.root.join('config', 'locales', '*.yml')]
        end

        def save(path, data)
          data.deep_transform_values! { |v| AbAdmin.normalize_html(v) }
          File.write path, data.deep_stringify_keys.to_yaml(line_width: YAML_LINE_WIDTH).sub(/\A---\s+/, '').gsub(/:\s+$/, ':').gsub(/^(\s+)(yes|no):/, '\1"\2":')
        end

        def prepare_data(path)
          data = YAML.load_file(path)
          locale = data.keys.first
          OpenStruct.new({locale: locale.to_sym, data: data[locale], flat_data: data[locale].flatten_hash,
                          filename: File.basename(path), path: path, dir: File.dirname(path)})
        end

        def export_csv(*keys, locales: nil, files: nil)
          return if keys.blank?
          sources = files.present? ? translations_for_files(files) : translations
          locales = locales.present? ? (I18n.available_locales & locales.map(&:to_sym)) : (sources.keys || I18n.available_locales)
          I18n.backend.available_locales # Force load translations
          filter_keys = keys.map {|k| k.include?('*') ? Regexp.new("\\A#{k.gsub('.', '\.').gsub('*', '.*')}\\z") : k}
          data = filter_keys.each_with_object(Hash.new { |h, k| h[k] = [] }) do |key, res|
            locales.each_with_index do |l, i|
              next unless sources[l]
              sources[l].find_all{|k, _| key.is_a?(Regexp) ? k =~ key : k == key }.each{|k, v| res[k][i] = v}
            end
          end
          for_csv = [['DO NOT EDIT THIS COLUMN!', *locales]] + data.map{|k, v| [k, *v] }
          for_csv.map(&:to_csv).join
        end

        def import_csv(csv, locales: nil)
          return if csv.blank?
          locales = locales.present? ? (I18n.available_locales & locales.map(&:to_sym)) : I18n.available_locales
          csv_data = CSV.parse(csv)
          csv_data.shift.each_with_index do |l, i|
            next if i.zero? || !locales.include?(l.to_sym)
            path = Rails.root.join('config', 'locales', "#{l}.yml")
            raise "Missing file #{path}" unless File.file?(path)
            data = YAML.load_file(path)
            csv_data.each do |d|
              key_parts = [l.to_s] + d[0].split('.')
              raise "Invalid key #{d[0]}" unless data.dig(*key_parts)
              data.store_multi(d[i], *key_parts)
            end
            save path, data
          end
        end

        def translations
          @translations ||= I18n.backend.send(:translations).slice(*I18n.available_locales).transform_values{|v| v.flatten_hash.transform_keys{|k| k.join('.') } }
        end

        def translations_for_files(files)
          data = {}
          files.each do |file|
            path = Rails.root.join('config', 'locales', file)
            puts path
            data.deep_merge!(YAML.load_file(path))
          end
          data.symbolize_keys.slice(*I18n.available_locales).transform_values{|v| v.flatten_hash.transform_keys{|k| k.join('.') } }
        end
      end

      def initialize
        @data = {}
        @files = self.class.find_files
      end

      def all
        @paths.each { |path| @data.deep_merge!(YAML.load_file(path)) }
        @data
      end

      def prepare_files
        message = nil
        locale_replace_regexp = Regexp.new("(^#{I18n.default_locale}|(?<=\.)#{I18n.default_locale}(?=\.yml))")

        locale_files = @files.map { |path| self.class.prepare_data(path) }
        main_locale_files = locale_files.find_all { |file| file.locale == I18n.default_locale }

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
        {message: message}
      end
    end
  end
end