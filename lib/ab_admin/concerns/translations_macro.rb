module AbAdmin
  module Concerns
    module TranslationsMacro
      def translates(*attr_names)
        options = attr_names.extract_options!
        setup_translations(options) unless translates?
        add_translated_attributes(attr_names.map(&:to_sym) - translated_attribute_names)
      end

      def setup_translations(options)
        include InstanceMethods
        extend ClassMethods

        class_attribute :translated_attribute_names, :translation_options
        self.translated_attribute_names = []
        self.translation_options = options

        has_many :translations, class_name: translation_class.name, foreign_key: class_name.foreign_key, dependent: :destroy, autosave: true, inverse_of: :translated_model
      end

      def add_translated_attributes(attr_names)
        attr_names.each do |attr_name|
          define_translation_accessors(attr_name)
          self.translated_attribute_names << attr_name
        end
      end

      def define_translation_accessors(attr_name)
        define_method("#{attr_name}_translation") { translation_for_locale(I18n.locale).try!(:send, attr_name) }
        define_method("#{attr_name}_translation=") {|v| translation_for_locale(I18n.locale).try!(:send, "#{attr_name}=", v) }
        alias_method attr_name, "#{attr_name}_translation"
        alias_method "#{attr_name}=", "#{attr_name}_translation="
        define_method("#{attr_name}_default"){ translation_for_locale(I18n.default_locale).try!(:send, attr_name) }
        AbAdmin.translated_locales.each do |l|
          define_method("#{attr_name}_#{l}") {translation_for_locale(l).try!(:send, attr_name)}
          define_method("#{attr_name}_#{l}=") {|v| translation_for_locale(l).try!(:send, "#{attr_name}=", v)}
        end
      end

      def class_name
        name.split('::').last
      end

      def translates?
        included_modules.include?(InstanceMethods)
      end

      module InstanceMethods
        def translation_for_locale(l)
          return unless AbAdmin.translated_locales.include?(l)
          translations.detect{|r| r.locale == l.to_s} || translations.new(locale: l.to_s)
        end

        def translated_attributes
          translated_attribute_names.map{|attr| [attr, send(attr)] }.to_h.stringify_keys
        end

        def attributes
          super.merge!(translated_attributes)
        end
      end

      module ClassMethods
        def translation_class
          @translation_class ||= begin
            klass = self.const_defined?(:Translation, false) ? self.const_get(:Translation, false) : self.const_set(:Translation, Class.new(BaseTranslation))
            klass.belongs_to :translated_model, class_name: self.name, foreign_key: class_name.foreign_key, inverse_of: :translations, touch: translation_options.fetch(:touch, false)
            klass
          end
        end

        def translations_table_name
          translation_class.table_name
        end

        def translated?(name)
          translated_attribute_names.include?(name.to_sym)
        end
      end
    end

    class BaseTranslation < ::ActiveRecord::Base
      self.abstract_class = true

      validates :locale, presence: true
      after_initialize :init

      def init
        self.locale ||= I18n.locale.to_s
      end

      def self.table_exists?
        table_name.present? && super
      end
    end
  end
end
