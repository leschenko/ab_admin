module AbAdmin
  module Views
    module Inputs
      class CkeditorInput < ::SimpleForm::Inputs::Base
        def input(wrapper_options=nil)
          input_html_options.reverse_merge!({width: 800, height: 200, data: {cdn_url: Ckeditor.cdn_url}})
          @builder.cktext_area(attribute_name, input_html_options)
        end
      end
    end
  end
end