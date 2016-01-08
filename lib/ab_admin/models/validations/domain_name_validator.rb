module ActiveModel
  module Validations
    class DomainNameValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute) unless value.to_s =~ ::AbAdmin::DOMAINNAME_REGEXP
      end
    end
  end
end
