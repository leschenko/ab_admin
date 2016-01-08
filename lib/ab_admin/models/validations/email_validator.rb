module ActiveModel
  module Validations
    class EmailValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute) unless value.to_s =~ ::AbAdmin::EMAIL_REGEXP
      end
    end
  end
end
