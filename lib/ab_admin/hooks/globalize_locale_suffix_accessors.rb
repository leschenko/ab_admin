# add accessors with locale suffix like `title_en`, `title_de`
module GlobalizeAccessorsWithLocaleSuffix
  def define_translations_reader(name)
    translation_attributes = class_variable_defined?(:@@translation_attributes) ? class_variable_get(:@@translation_attributes) : []

    super(name)

    Globalize.available_locales.each do |locale|
      method_name = "#{name}_#{locale}"
      define_method method_name.to_sym do
        read_attribute(name, {locale: locale})
      end
      translation_attributes.push(method_name)
    end
    class_variable_set(:@@translation_attributes, translation_attributes)
  end

  def define_translations_writer(name)
    super(name)

    Globalize.available_locales.each do |locale|
      define_method :"#{name}_#{locale}=" do |value|
        changed_attributes
        @changed_attributes[:"#{name}_#{locale}"] = value unless value == read_attribute(name, {locale: locale})
        write_attribute(name, value, {locale: locale})
      end
    end
  end
end

Globalize::ActiveRecord::ClassMethods.module_eval do
  prepend GlobalizeAccessorsWithLocaleSuffix
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