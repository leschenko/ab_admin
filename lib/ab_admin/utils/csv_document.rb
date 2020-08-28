require 'csv'

module AbAdmin
  module Utils
    class CsvDocument
      def initialize(source, options = {})
        @source = source
        @options = options
        @klass = @options.delete(:klass) || extract_klass
      end

      def default_columns
        @default_columns ||= @klass.column_names
      end

      def column_data
        @columns_names ||= @options[:column_data] || default_columns
      end

      def columns_names
        (@options[:column_names] || default_columns).map { |column| column.is_a?(Symbol) ? @klass.human_attribute_name(column) : column }
      end

      def filename
        @filename ||= [@options[:filename] || "#{@klass.model_name.plural}-#{Time.now.strftime('%Y-%m-%d')}", '.csv'].join
      end

      def render(context=nil, options={})
        ::CSV.generate(col_sep: @options[:column_separator] || ',') do |csv|
          csv << columns_names

          I18n.with_locale options[:locale] do
            each_record do |item|
              csv << column_data.map do |column|
                value = column.is_a?(Symbol) ? item.public_send(column) : context.instance_exec(item, &column)
                AbAdmin.pretty_data value
              end
            end
          end
        end
      end

      def each_record
        if @source.respond_to?(:find_each)
          @source.find_each do |item|
            yield item
          end
        else
          Array(@source).each do |item|
            yield item
          end
        end
      end

      protected

      def extract_klass
        if @source.respond_to?(:klass)
          @source.klass
        elsif @source.is_a?(Array)
          @source.first.try(:class)
        else
          @source.class
        end
      end
    end
  end
end
