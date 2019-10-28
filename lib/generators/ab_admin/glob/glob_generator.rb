require 'rails/generators/active_record'
module AbAdmin
  module Generators
    class GlobGenerator < ActiveRecord::Generators::Base
      desc 'Generates migration for models without translations tables'

      source_root File.expand_path('../templates', __FILE__)

      argument :name, type: :string, default: ''

      def create_glob_migration
        migration_template 'migration.erb', "db/migrate/#{migration_name}.rb"
      end

      protected

      def model_attrs
        @model_attrs ||= begin
          models.each_with_object({}) do |m, h|
            h[m.name] = m.translated_attribute_names.map { |attr| [attr, get_type(attr)] }
          end
        end
      end

      def migration_name
        "create_translations_#{models.map { |m| m.model_name.singular }.join('_')}"
      end

      def models
        @models ||= begin
          all_translated.reject { |m| conn.data_source_exists? m.translation_class.table_name }
        end
      end

      def all_translated
        all_models.find_all { |m| m.translates? }
      end

      def all_models
        Dir.glob(Rails.root.to_s + '/app/models/**/*.rb').reject { |path| path =~ /concerns|shared/ }.each { |file| require file }
        [ActiveRecord::Base, ApplicationRecord].flat_map{|sc| sc.subclasses.find_all { |model| model.connection.table_exists?(model.table_name) } }
      end

      def conn
        @conn ||= ActiveRecord::Base.connection
      end

      def get_type(col)
        case col.to_sym
          when :description, :content, :content_short
            :text
          else
            :string
        end
      end
    end
  end
end
