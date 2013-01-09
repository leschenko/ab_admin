module WrappedButton
  def wrapped_button(*args, &block)
    template.content_tag :div, :class => "form-actions" do
      options = args.extract_options!
      loading = self.object.new_record? ? I18n.t('simple_form.creating') : I18n.t('simple_form.updating')
      options[:"data-loading-text"] = [loading, options[:"data-loading-text"]].compact
      options[:class] = ['btn-primary', options[:class]].compact
      args << options
      if cancel = options.delete(:cancel)
        submit(*args, &block) + ' ' + template.link_to(I18n.t('simple_form.buttons.cancel'), cancel, :class => 'btn')
      else
        submit(*args, &block)
      end
    end
  end
end
SimpleForm::FormBuilder.send :include, WrappedButton

module SimpleForm
  module Inputs
    class DateTimeInput < Base
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

module SimpleForm
  module Inputs
    class CollectionRadioButtonsInput
      def item_wrapper_class
        "radio #{options.delete(:item_wrapper_class)}"
      end
    end
  end
end

module SimpleForm
  module Inputs
    class CollectionCheckBoxesInput
      def item_wrapper_class
        "radio #{options.delete(:item_wrapper_class)}"
      end
    end
  end
end

