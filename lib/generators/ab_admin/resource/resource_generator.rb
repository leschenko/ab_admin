# -*- encoding : utf-8 -*-
module AbAdmin
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      desc 'Generates AbAdmin_resource for model'

      argument :model_name, :type => :string, :required => true
      #class_option :engine, :type => :string, :description => 'Template engine', :aliases => '-e'
      class_option :no_form, :type => :boolean, :default => false, :description => 'Don\'t create form template' #, :aliases => '-r'
      class_option :no_table, :type => :boolean, :default => false, :description => 'Don\'t create table template'
      class_option :no_search_form, :type => :boolean, :default => false, :description => 'Don\'t create search_form template'

      hook_for :template_engine
      hook_for :helper

      def create_controller_files
        template 'controller.erb', File.join('app/controllers/admin', "#{controller_file_name}_controller.rb")
        template 'helper.rb', File.join('app/helpers/admin', "#{controller_file_name}_helper.rb")
      end

      def create_views_files
        template("form.#{engine}.erb", "app/views/admin/#{controller_file_name}/_form.html.#{engine}") unless options.no_form?
        template("table.#{engine}.erb", "app/views/admin/#{controller_file_name}/_table.html.#{engine}") unless options.no_table?
        template("search_form.#{engine}.erb", "app/views/admin/#{controller_file_name}/_search_form.html.#{engine}") unless options.no_search_form?
        say "add to config/routes.rb\n  resources(:#{controller_file_name}) { post :batch, :on => :collection }"
        say "add to layouts/_navigation.html.#{engine}\n  = model_admin_menu_link(#{model_class.name})"
      end

      def engine
        @engine ||= begin
          engine = options.engine.presence || Rails.application.config.app_generators.options[:rails][:template_engine].to_s
          if %w(haml slim).include?(engine)
            engine
          else
            say_status 'error', "No available template engine '#{engine}' in generator", :red
            exit false
          end
        end
      end

      def model_key
        @model_key ||= model_class.model_name.i18n_key.to_s
      end

      def model_class
        @model_class ||= model_name.camelcase.constantize
      end

      def model
        @model ||= model_class.new
      end

      def controller_class_name
        @controller_class_name ||= model_class.model_name.plural.camelize
      end

      def controller_file_name
        @controller_file_name ||= model_class.model_name.plural
      end

      def translated_columns
        @translated_columns ||= model_class.translated_attribute_names if model_class.respond_to?(:translated_attribute_names)
        @translated_columns ||= []
      end

    end
  end
end
