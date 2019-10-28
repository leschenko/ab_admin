module AbAdmin
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      desc 'Generates AbAdmin dsl resource for model'

      source_root File.expand_path('../templates', __FILE__)
      check_class_collision prefix: 'AbAdmin'

      def create_resource_file
        template 'resource.erb', File.join('app/models/ab_admin', "ab_admin_#{singular_name}.rb")
      end

      def add_menu
        menu_path = 'app/models/admin_menu.rb'
        return if File.read(File.join(@destination_stack.last, menu_path)).match(Regexp.new("[^a-zA-Z]#{model.name}[^a-zA-Z]"))
        menu_code = "model #{model.name}"
        log :menu, menu_code
        sentinel = /draw do$/

        in_root do
          inject_into_file menu_path, "\n    #{menu_code}\n", {after: sentinel, verbose: false}
        end
      end

      def model
        @model ||= class_name.constantize
      end

      protected

      def model_instance
        model.new
      end

      def translated_columns
        model.respond_to?(:translated_attribute_names) ? model.translated_attribute_names.map(&:to_s) : []
      end

      def index_attrs
        model_instance.attributes.keys.map(&:to_s)
      end
    end
  end
end
