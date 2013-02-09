module AbAdmin
  module Views
    module Inputs
      class DateTimeInput < ::SimpleForm::Inputs::Base
        def input
          if options[:no_js]
            return @builder.send(:"#{input_type}_select", attribute_name, input_options, input_html_options)
          end

          input_html_options[:value] ||= formated_value

          html = [@builder.hidden_field(attribute_name, input_html_options)]

          base_dom_id = @builder.object_name.gsub(/\[/, '_').gsub(/\]/, '')
          data_target = "#{base_dom_id}_#{attribute_name}"

          if [:date, :datetime].include? input_type
            attr = "#{data_target}_date"
            html << template.text_field_tag(attr, object.send(attribute_name).try(:strftime, "%d.%m.%Y"), :id => attr,
                                            :class => 'datepicker input-small', :data => {:target => data_target})
          end

          if [:time, :datetime].include? input_type
            attr = "#{data_target}_time"
            html << template.text_field(attr, object.send(attribute_name).try(:strftime, "%H:%M"), :id => attr,
                                        :class => 'timepicker input-small', :data => {:target => data_target})
          end

          html.join.html_safe
        end

        private

        def formated_value
          object.send(attribute_name).try(:strftime, value_format)
        end

        def value_format
          case input_type
            when :date then
              "%d.%m.%Y"
            when :datetime then
              "%d.%m.%Y %H:%M"
            when :time then
              "%H:%M"
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
