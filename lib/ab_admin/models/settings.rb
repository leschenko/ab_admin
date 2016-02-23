module AbAdmin
  module Models
    module Settings
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Naming
        extend ActiveRecord::Translation
        class_attribute :base_class, :base_dir, :base_paths, :editable_paths
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
      end

      module ClassMethods
        def load_config
          configatron.configure_from_hash instance.all
          configatron
        end
      end

      def initialize
        @data = {}
        @paths = find_paths
      end

      def editable
        return {} unless  editable_path
        YAML.load_file(editable_path) rescue {}
      end

      def save(raw_config)
        config = {}
        raw_config.each do |root_key, root_value|
          if root_value.is_a?(Hash)
            config[root_key] ||= {}
            root_value.each do |key, value|
              config[root_key][key] = typecast_value(value)
            end
          else
            config[root_key] = typecast_value(root_value)
          end
        end
        return unless editable_path
        File.open(editable_path, 'w') { |file| file.write config.to_yaml } and self.class.load_config
      end

      def all
        @paths.each do |path|
          @data.deep_merge!(YAML.load_file(path))
        end
        @data
      end

      private

      def editable_path
        @editable_path ||= editable_paths.detect { |path| File.exists?(path) }
      end

      def find_paths
        base_paths.dup.unshift(editable_path).compact.find_all { |path| File.exists?(path) }
      end

      def typecast_value(value)
        if %w(true false).include?(value) || value.to_s.is_number?
          YAML::load(value)
        else
          value
        end
      end

    end
  end
end