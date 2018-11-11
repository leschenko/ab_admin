module AbAdmin
  module Views
    module Inputs
      class DateTimePickerInput < ::SimpleForm::Inputs::Base
        def input(wrapper_options=nil)
          input_html_options[:value] ||= formatted_value
          input_html_options[:autocomplete] ||= 'off'
          input_html_classes << input_type
          @builder.text_field(attribute_name, input_html_options)
        end

        private

        def formatted_value
          object.send(attribute_name).try(:strftime, value_format)
        end

        def value_format
          case input_type
            when :date_picker
              '%Y-%m-%d'
            when :datetime_picker
              '%Y-%m-%d %H:%M'
            when :time_picker
              '%H:%M'
          end
        end

        def has_required?
          false
        end

        def label_target
          case input_type
            when :date, :datetime
              "#{attribute_name}_1i"
            when :time
              "#{attribute_name}_4i"
          end
        end
      end
    end
  end
end
