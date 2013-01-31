module AbAdmin
  module Views
    module Inputs
      class ColorInput < ::SimpleForm::Inputs::Base
        def input
          value = @builder.object[attribute_name].to_s.sub(/^#|/, '#')
          name = "#{@builder.object_name}[#{attribute_name}]"
          @builder.template.tag(:input, input_html_options.merge(:type => 'color', :name => name, :value => value))
        end
      end
    end
  end
end
