module AbAdmin
  module Views
    module Inputs
      class AssociationInput < ::SimpleForm::Inputs::CollectionSelectInput
        def input
          options[:collection] ||= object.class.reflect_on_association(attribute_name).klass.all
          @attribute_name = "#{attribute_name}_id"
          super
        end
      end
    end
  end
end
