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

      class << self
        def define_enum_by_codes
          define_enum do |builder|
            codes.each do |kind|
              builder.member kind, object: new(kind.to_s)
            end
          end
          define_question_methods
        end

        def define_question_methods
          codes.each do |code_check|
            define_method "#{code_check}?" do
              self.code == code_check
            end
          end
        end

        def legal?(value)
          ActiveSupport::Deprecation.warn('legal? id deprecated, use valid? instead')
          valid?(value)
        end

        def valid?(c_id)
          all.map(&:id).include?(c_id.to_i)
        end

        def valid_code?(code)
          return unless code
          codes.include?(code.to_sym)
        end
      end

      def title
        I18n.t!(@code, scope: i18n_scope)
      rescue I18n::MissingTranslationData
        @code.to_s.humanize
      end

    end
  end
end