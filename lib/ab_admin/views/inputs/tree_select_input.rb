module AbAdmin
  module Views
    module Inputs
      class TreeSelectInput < ::SimpleForm::Inputs::CollectionSelectInput
        def input
          options[:collection] ||= begin
            collection_class = options.delete(:collection_class) || object.class
            object.nested_opts(collection_class.all)
          end
          options[:collection] ||= []
          super
        end
      end
    end
  end
end
