module AbAdmin
  module Config
    class BaseBuilder
      attr_reader :options, :fields
      class_attribute :field_defaults, :instance_writer => false
      self.field_defaults = {}

      def initialize(options={}, &block)
        @fields = []
        @options = options
        instance_eval(&block) if block_given?
      end

      def field(name, options={}, &block)
        @fields << Field.new(name, options.reverse_merge!(field_defaults), &block)
      end

      def self.default_for_model(model, options={})
        new.tap do |builder|
          builder.field(:id)
          model.content_columns.each do |column|
            column_name = column.name.to_sym
            next if options[:skip].try(:include?, column_name)
            builder.field(column_name)
          end
        end
      end
    end

    class Table < BaseBuilder
      self.field_defaults = {:sortable => true}
    end

    class Search < BaseBuilder

    end

    class Export < BaseBuilder

    end

    class Form < BaseBuilder
      def group(name=nil, options={}, &block)
        options[:title] = name || :base
        @fields << FieldGroup.new(options, &block)
      end

      def locale_tabs(options={}, &block)
        @fields << FieldGroup.new(options.update(:localized => true), &block)
      end
    end

    class FieldGroup < BaseBuilder
      def title
        options[:title].is_a?(Symbol) ? I18n.t(options[:title], :scope => [:admin, :form]) : options[:title]
      end

      def localized?
        options[:localized]
      end

      def group?
        true
      end
    end

    class Field
      attr_reader :name, :options, :data

      def initialize(name, options={}, &block)
        @name = name
        @options = options
        @data = block_given? ? block : name.to_sym
      end

      def group?
        false
      end
    end

  end
end