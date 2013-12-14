module AbAdmin
  module Models
    module Settings
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Naming
        extend ActiveRecord::Translation
        class_attribute :base_class, :editable_paths
        self.base_class = self
        self.editable_paths = [
            Rails.root.join('config', 'settings', "#{Rails.env}.local.yml"),
            Rails.root.join('config', 'settings', 'settings.local.yml')
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
        @editable_path = find_editable_path
        @paths = find_paths
      end

      def find_editable_path
        path = editable_paths.detect { |path| File.exists?(path) }
        path or raise("Create settings file for editing: #{editable_paths.join(' or ')}")
      end

      def find_paths
        [
            Rails.root.join('config', 'settings', 'settings.yml'),
            Rails.root.join('config', 'settings', "#{Rails.env}.yml"),
            @editable_path
        ].find_all { |path| File.exists?(path) }
      end

      def all
        @paths.each do |path|
          @data.deep_merge!(YAML.load_file(path))
        end
        @data
      end

      def editable
        YAML.load_file(@editable_path) rescue {}
      end

      def save(raw_config)
        conf = {}
        raw_config.each do |root_key, root_value|
          if root_value.is_a?(Hash)
            conf[root_key] ||= {}
            root_value.each do |key, value|
              conf[root_key][key] = case_value(value)
            end
          else
            conf[root_key] = case_value(root_value)
          end
        end
        File.open(@editable_path, 'w') { |file| file.write conf.to_yaml } and self.class.load_config
      end

      def case_value(value)
        if %w(true false 1 0).include?(value) || value.to_s.is_number?
          YAML::load(value)
        else
          value
        end
      end

    end
  end
end