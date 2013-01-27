module AbAdmin
  module Views
    module Inputs
      class EditorInput < ::SimpleForm::Inputs::TextInput
        def input
          input_html_options[:class] = "#{input_html_options[:class]} do_wysihtml5"
          super
        end
      end
    end
  end
end
