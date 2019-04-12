module AbAdmin
  module Models
    module Settings
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Naming
        extend ActiveRecord::Translation
        class_attribute :data_cache, :base_class, :base_dir, :base_paths, :editable_paths
        self.base_class = self
        self.base_dir = Rails.root.join('config', 'settings')
        self.base_paths = [
            File.join(base_dir, 'settings.yml'),
            File.join(base_dir, "#{Rails.env}.yml")
        ]
        self.editable_paths = [
            File.join(base_dir, "#{Rails.env}.local.yml"),
            File.join(base_dir, 'settings.local.yml')
        ]

        class << self
          delegate :get, :dig, to: :data, allow_nil: true
        end
      end

      module ClassMethods
        def load_config
          ActiveSupport::Deprecation.warn('`Settings.load_config` is deprecated, use `Settings.data` instead')
          data
        end

        def data
          self.data_cache ||= read_data
        end

        def read_data
          paths = base_paths.dup.push(editable_path).compact.find_all { |path| File.exists?(path) }
          hash = paths.map{|path| YAML.safe_load(File.read(path)) }.inject(&:deep_merge).deep_symbolize_keys
          SettingsStruct.new(hash)
        end

        def editable_data
          YAML.safe_load(File.read(editable_path))
        end

        def update(raw_config)
          data = YAML.safe_load(YAML.dump(raw_config.to_hash.deep_stringify_keys.deep_transform_values!{|v| YAML.safe_load(v) }))
          File.write(editable_path, data.to_yaml) and load_config
        end

        def editable_path
          editable_paths.detect { |path| File.exists?(path) }
        end
      end

      class SettingsStruct < OpenStruct
        def initialize(hash=nil)
          @table = {}
          return unless hash
          hash.symbolize_keys.each do |k, v|
            k = k.to_sym
            @table[k] = v.is_a?(Hash) ? SettingsStruct.new(v.symbolize_keys) : v
          end
        end

        def get(key)
          dig *key.split('.').map(&:to_sym)
        end
      end
    end
  end
end