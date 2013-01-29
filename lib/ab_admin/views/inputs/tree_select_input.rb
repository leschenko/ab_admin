module AbAdmin
  module Views
    module Inputs
      class TreeSelectInput < ::SimpleForm::Inputs::CollectionSelectInput
        def input
          options[:collection] ||= begin
            collection_class = options.delete(:collection_class) || object.class
            @template.nested_set_options(collection_class) { |i| "#{'–'*i.depth} #{i.title}" }.delete_if { |i| i[1] == object.id }
            ['ad']
          end
          options[:collection] ||= []
          super
        end
      end
    end
  end
end
