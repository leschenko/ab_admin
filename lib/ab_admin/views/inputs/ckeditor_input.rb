module AbAdmin
  module Views
    module Inputs
      class CkeditorInput < ::SimpleForm::Inputs::Base
        def input(wrapper_options=nil)
          unless @builder.template.instance_variable_get(:@ckeditor_init)
            @builder.template.concat @builder.template.javascript_include_tag('/javascripts/ckeditor/init')
            @builder.template.instance_variable_set(:@ckeditor_init, true)
          end
          input_html_options.reverse_merge!({width: 800, height: 200, toolbar: 'Easy'})
          @builder.cktext_area(attribute_name, input_html_options)
        end
      end
    end
  end
end