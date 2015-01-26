# add accessors with locale suffix like `title_en`, `title_de`
Globalize::ActiveRecord::ClassMethods.module_eval do
  def define_translations_reader_with_locale_suffix(name)
    translation_attributes = class_variable_defined?(:@@translation_attributes) ? class_variable_get(:@@translation_attributes) : []

    define_translations_reader_without_locale_suffix(name)

    Globalize.available_locales.each do |locale|
      method_name = "#{name}_#{locale}"
      define_method method_name.to_sym do
        read_attribute(name, {locale: locale})
      end
      translation_attributes.push(method_name)
    end
    class_variable_set(:@@translation_attributes, translation_attributes)
  end

  alias_method_chain :define_translations_reader, :locale_suffix

  def define_translations_writer_with_locale_suffix(name)
    define_translations_writer_without_locale_suffix(name)

    Globalize.available_locales.each do |locale|
      define_method :"#{name}_#{locale}=" do |value|
        @changed_attributes[:"#{name}_#{locale}"] = value unless value == read_attribute(name, {locale: locale})
        write_attribute(name, value, {locale: locale})
      end
    end
  end

  alias_method_chain :define_translations_writer, :locale_suffix
end

Globalize::ActiveRecord::InstanceMethods.module_eval do
  private

  # Filters translation attributes from the attribute names.
  def attributes_for_update(attribute_names)
    filter_translation_attributes(super)
  end

  # Filters translation attributes from the attribute names.
  def attributes_for_create(attribute_names)
    filter_translation_attributes(super)
  end

  def filter_translation_attributes(attributes)
    translation_attributes = self.class.class_variable_get(:@@translation_attributes)
    attributes.delete_if { |attr| translation_attributes.include? attr }
  end
end

Globalize::ActiveRecord::Translation.attr_accessible :locale