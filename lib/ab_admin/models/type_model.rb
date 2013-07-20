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
        I18n.t!(@code, scope: i18n_scope)
      rescue I18n::MissingTranslationData
        @code.to_s.humanize
      end

      def self.legal?(value)
        ActiveSupport::Deprecation.warn('legal? id deprecated, use valid? instead')
        all.map(&:id).include?(value)
      end

      def self.valid?(c_id)
        all.map(&:id).include?(c_id.to_i)
      end

      def self.valid_code?(code)
        return unless code
        codes.include?(code.to_sym)
      end

    end
  end
end