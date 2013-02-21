module AbAdmin
  module Models
    class TypeModel
      include ::EnumField::DefineEnum

      attr_reader :code

      class_attribute :codes, :i18n_scope, instance_writer: false
      self.codes = []
      self.i18n_scope = [:admin, :type_model]

      def initialize(code)
        @code = code.to_sym
      end

      def self.define_enum_by_codes
        define_enum do |builder|
          codes.each do |kind|
            builder.member kind, object: new(kind.to_s)
          end
        end
      end

      def title
        I18n.t(@code, scope: i18n_scope)
      end

      def self.legal?(value)
        all.map(&:id).include?(value)
      end

    end
  end
end