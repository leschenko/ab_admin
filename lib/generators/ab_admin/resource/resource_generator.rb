# -*- encoding : utf-8 -*-
module AbAdmin
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      desc 'Generates AbAdmin_resource for model'

      source_root File.expand_path('../templates', __FILE__)
      check_class_collision :suffix => 'Controller', :prefix => 'Admin::'

      class_option :handler, :default => 'slim', :desc => 'Template engine to be invoked (haml or slim).', :aliases => '-e'
      class_option :skip_form, :type => :boolean, :default => false, :description => 'Don\'t create form template' #, :aliases => '-r'
      class_option :skip_table, :type => :boolean, :default => false, :description => 'Don\'t create table template'
      class_option :skip_search_form, :type => :boolean, :default => false, :description => 'Don\'t create search_form template'

      hook_for :helper, :in => :rails do |instance, helper|
        instance.invoke helper, ["admin/#{instance.send(:plural_name)}"]
      end

      def create_controller_files
        template 'controller.erb', File.join('app/controllers/admin', "#{controller_file_name}_controller.rb")
      end

      def add_routes
        say "add to config/routes.rb\n  resources(:#{controller_file_name}) { post :batch, :on => :collection }"
        #say "add to layouts/_navigation.html.#{template_engine}\n  = model_admin_menu_link(#{model_class.name})"
      end

      def create_view_files
        empty_directory File.join('app/views', controller_file_path)
        available_views.each do |view|
          next if options.send("skip_#{view.sub(/^_/, '')}?")
          template "#{view}.#{options[:handler]}.erb", File.join('app/views/admin', controller_file_path, view_filename_with_extensions(view))
        end
      end

      def model
        @model ||= class_name.constantize
      end

      protected

      def view_filename_with_extensions(name)
        [name, :html, options[:handler]].compact.join('.')
      end

      def available_views
        %w(_form _table _search_form)
      end

      def model_instance
        @model_instance ||= model.new
      end

      #def singular_name
      #
      #end

      def translated_columns
        @translated_columns ||= model.translated_attribute_names if model.respond_to?(:translated_attribute_names)
        @translated_columns ||= []
      end

    end
  end
end
