module AbAdmin
  module Views
    module Inputs
      class TokenInput < ::SimpleForm::Inputs::StringInput

        def input
          attr = options.delete(:assoc) || attribute_name.to_s.sub(/^token_|_id$/, '')
          input_html_options.reverse_deep_merge!(object.token_data(attr.to_sym, options.extract!(:geo_order, :c)))
          super
        end

      end
    end
  end
end
