require 'write_xlsx'
require 'stringio'

module AbAdmin
  module Utils
    class Default
      extend ActiveModel::Naming

      def self.human_attribute_name(*)
        ''
      end
    end

    class XlsDocument
      def initialize(source, options = {})
        @source = source
        @options = options
        @compiled = false
        @io = ::StringIO.new
      end

      def workbook
        @workbook ||= ::WriteXLSX.new(@io)
      end

      def worksheet
        @worksheet ||= add_worksheet(worksheet_name)
      end

      def add_worksheet(*args)
        @worksheet = workbook.add_worksheet(*args)
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
        @filename ||= [@options[:filename] || "#{@klass.model_name.plural}-#{Time.now.strftime('%Y-%m-%d')}", '.xlsx'].join
      end

      def render(context, options={})
        date_format = workbook.add_format(num_format: 'dd.mm.yyyy')
        time_format = workbook.add_format(num_format: 'dd.mm.yyyy HH:MM')

        I18n.with_locale options[:locale] do
          each_with_index do |item, index|
            row = index + 1

            column_data.each_with_index do |column, num|
              value = column.is_a?(Symbol) ? item.public_send(column) : context.instance_exec(&column)

              case value
                when Date
                  worksheet.write_string(row, num, value.strftime('%Y-%m-%dT'), date_format)
                when DateTime, Time
                  worksheet.write_date_time(row, num, value.strftime('%Y-%m-%dT%H:%M:%S.%L'), time_format)
                when String
                  worksheet.write_string(row, num, value)
                else
                  worksheet.write(row, num, AbAdmin.pretty_data(value))
              end
            end
          end
        end

        bold = workbook.add_format(bold: 1)
        worksheet.write('A1', columns_names, bold)

        workbook.close
        @io.string
      end

      def worksheet_name
        @worksheet_name ||= (@options[:worksheet_name] || @klass.model_name.human)
      end

      def each_with_index
        count = 0
        if @source.is_a?(::ActiveRecord::Relation)
          @klass ||= @source.klass

          @source.find_each do |item|
            yield item, count
            count += 1
          end
        else
          items = @source.respond_to?(:to_a) ? @source.to_a : Array.wrap(@source)
          @klass ||= items.first.class unless items.empty?
          @klass ||= Default

          items.each do |item|
            yield item, count
            count += 1
          end
        end
      end
    end
  end
end
