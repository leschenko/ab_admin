# add accessors with locale suffix like `title_en`, `title_de`
module GlobalizeAccessorsWithLocaleSuffix
  def define_translated_attr_reader(name)
    super

    Globalize.available_locales.each do |locale|
      method_name = "#{name}_#{locale}"
      define_method method_name.to_sym do
        Globalize::Interpolation.interpolate(name, self, [locale])
      end
    end
  end

  def define_translated_attr_writer(name)
    super

    Globalize.available_locales.each do |locale|
      define_method :"#{name}_#{locale}=" do |value|
        write_attribute(name, value, {locale: locale})
      end
    end
  end
end

Globalize::ActiveRecord::ClassMethods.module_eval do
  prepend GlobalizeAccessorsWithLocaleSuffix
end