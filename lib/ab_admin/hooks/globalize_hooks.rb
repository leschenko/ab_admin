module Globalize
  mattr_accessor :available_locales

  def self.valid_locale?(loc)
    return false unless loc
    available_locales.include?(loc.to_sym)
  end
end

Globalize::ActiveRecord::ClassMethods.module_eval do
  def translations_accessor_with_locale_suffix_accessors(name)
    translations_accessor_without_locale_suffix_accessors(name)

    Globalize.available_locales.each do |locale|
      define_method :"#{name}_#{locale}" do
        read_attribute(name, {locale: locale})
      end

      define_method :"#{name}_#{locale}=" do |value|
        changed_attributes[:"#{name}_#{locale}"] = value unless value == read_attribute(name, {locale: locale})
        write_attribute(name, value, {locale: locale})
      end
    end
  end
  alias_method_chain :translations_accessor, :locale_suffix_accessors
end

Globalize::ActiveRecord::Translation.class_exec do
  attr_accessible :locale
end