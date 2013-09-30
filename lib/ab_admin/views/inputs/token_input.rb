module AbAdmin
  module Views
    module Inputs
      class TokenInput < ::SimpleForm::Inputs::StringInput

        def input
          attr = options.delete(:assoc) || attribute_name.to_s.sub(/^token_|_id$/, '')
          token_data = object.token_data(attr.to_sym, options.extract!(:geo_order, :c, :sortable))
          input_html_options.reverse_deep_merge!(token_data)
          super
        end

      end
    end
  end
end
