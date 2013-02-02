module AbAdmin
  module Config
    class BaseBuilder
      attr_reader :options, :fields
      class_attribute :field_defaults, :instance_writer => false
      self.field_defaults = {}

      def initialize(options, &block)
        @fields = []
        @options = options
        instance_eval(&block) if block_given?
      end

      def field(name, options={}, &block)
        @fields << Field.new(name, options.reverse_merge!(field_defaults), block)
      end

      def self.default_for_model(model)
        new.tap do |builder|
          builder.field(:id)
          model.content_columns.each do |column|
            builder.field(column.name.to_sym)
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

    class Field
      attr_reader :name, :options, :data

      def initialize(name, options={}, block=nil)
        @name = name
        @options = options
        @data = block || name.to_sym
      end
    end

  end
end