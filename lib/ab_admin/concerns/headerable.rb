module AbAdmin
  module Concerns
    module Headerable
      extend ActiveSupport::Concern

      included do
        has_one :header, as: :headerable, dependent: :delete

        accepts_nested_attributes_for :header, reject_if: :all_blank

        ::Header.all_translated_attribute_names.each do |attr|
          define_method "header_#{attr}=" do |val|
            default_header.send("#{attr}=", val)
          end

          define_method "header_#{attr}" do
            default_header.send(attr)
          end
        end
      end

      def default_header
        header || build_header
      end

      def default_persistent_header
        header || create_header
      end
    end
  end
end
