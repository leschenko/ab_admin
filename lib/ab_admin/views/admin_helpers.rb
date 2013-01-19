# -*- encoding : utf-8 -*-
module AbAdmin
  module Views
    module AdminHelpers

      def admin_form_for(object, *args, &block)
        options = args.extract_options!
        options[:html] ||= {}
        options[:html][:class] ||= 'form-horizontal'
        options[:builder] ||= ::AbAdmin::Views::FormBuilder
        options[:html]['data-id'] = object.id
        if options.delete(:nested)
          simple_nested_form_for([:admin, object].flatten, *(args << options), &block)
        else
          simple_form_for([:admin, object].flatten, *(args << options), &block)
        end
      end

      def options_for_ckeditor(options = {})
        {:width => 930, :height => 200, :toolbar => 'VeryEasy', :namespace => ''}.update(options)
      end

    end
  end
end
