module AbAdmin
  module Config
    class BaseBuilder
      attr_reader :options, :fields
      attr_accessor :partial
      class_attribute :partial_name, instance_writer: false

      def initialize(options={}, &block)
        @fields = []
        @options = options
        @partial = options[:partial]
        instance_eval(&block) if block_given?
      end

      def field(name, options={}, &block)
        @fields << Field.new(name, options, &block)
      end

      def self.default_for_model(model, options={})
        new.tap do |builder|
          model.column_names.each do |column|
            column_name = column.to_sym
            next if column_name == :id || options[:skip].try(:include?, column_name)
            builder.field(column_name)
          end
        end
      end
    end

    class Table < BaseBuilder
      self.partial_name = 'table'
    end

    class Search < BaseBuilder
      self.partial_name = 'search_form'
    end

    class Chart < BaseBuilder
      self.partial_name = 'chart'
    end

    class Export < BaseBuilder
      def render_options
        {column_names: fields.map(&:name), column_data: fields.map(&:data),
         column_separator: options[:column_separator], worksheet_name: options[:worksheet_name],
         filename: options[:filename]}
      end
    end

    class Form < BaseBuilder
      self.partial_name = 'form'

      def group(name=nil, options={}, &block)
        options[:title] = name || :base
        @fields << FieldGroup.new(options, &block)
      end

      def locale_tabs(options={}, &block)
        @fields << FieldGroup.new(options.update(localized: true), &block)
      end
    end

    class ModalForm < Form
      self.partial_name = 'modal_form'
    end

    class Show < BaseBuilder
      self.partial_name = 'show_table'

      def self.default_for_model(model, options={})
        new.tap do |builder|
          model.new.attributes.each_key do |attr|
            column_name = attr.to_sym
            next if options[:skip].try(:include?, column_name)
            builder.field(column_name)
          end
        end
      end
    end

    class FieldGroup < BaseBuilder
      def title
        options[:title].is_a?(Symbol) ? I18n.t(options[:title], scope: [:admin, :form]) : options[:title]
      end

      def localized?
        options[:localized]
      end

      def group?
        true
      end
    end

    class Field
      attr_reader :name, :options, :block

      def initialize(name, options={}, &block)
        @name = name
        @options = options
        @block = block
      end

      def data
        @block || name.to_sym
      end

      def group?
        false
      end
    end

    class BatchAction
      attr_reader :name, :options, :data, :title, :form

      def initialize(name, options={}, &block)
        @name = name
        @options = options
        if options.has_key?(:form)
          @form = options[:form].is_a?(String) ? options[:form] : "##{name}_batch_form"
        end
        @title = options[:title] || I18n.t("admin.actions.batch_#{name}.link", default: name.to_s.humanize)
        @data = block_given? ? block : name.to_sym
      end

      def confirm
        options[:confirm]
      end
    end

    class ActionItem
      include AbAdmin::Config::OptionalDisplay

      attr_reader :options, :data

      def initialize(options={}, &block)
        raise 'Can not create action item without a block' unless block_given?
        @options = options
        @data = block
        normalize_display_options!
      end
    end

    class CustomAction
      include AbAdmin::Config::OptionalDisplay

      attr_reader :name, :options, :data

      def initialize(name, options={}, &block)
        raise 'Can not create member action without a block' unless block_given?
        @name = name
        @options = options
        @data = block
        normalize_display_options!
      end

      def collection?
        options[:collection]
      end
    end

    class Scope
      attr_reader :name, :options, :data

      def initialize(name, options={}, &block)
        @name = name
        @options = options
        @options[:badge] = {} if @options[:badge] && !@options[:badge].is_a?(Hash)
        @data = block
      end

      def apply(relation, params)
        data.is_a?(Proc) ? data.call(relation, params) : relation.public_send(name)
      end
    end
  end
end
