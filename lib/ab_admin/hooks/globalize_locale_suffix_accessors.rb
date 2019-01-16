# add accessors with locale suffix like `title_en`, `title_de`
module GlobalizeAccessorsWithLocaleSuffix
  def define_translated_attr_reader(name)
    super

    Globalize.available_locales.each do |locale|
      method_name = "#{name}_#{locale}"
      # attribute(method_name, ::ActiveRecord::Type::Value.new)
      define_method method_name.to_sym do
        I18n.with_locale(locale) do
          Globalize::Interpolation.interpolate(name, self, [locale])
        end
      end
    end
  end

  def define_translated_attr_writer(name)
    super

    Globalize.available_locales.each do |locale|
      define_method "#{name}_#{locale}=".to_sym do |value|
        I18n.with_locale(locale) do
          write_attribute(name.to_s, value, {locale: locale})
        end
      end
    end
  end
end

Globalize::ActiveRecord::ClassMethods.module_eval do
  prepend GlobalizeAccessorsWithLocaleSuffix
end


# module GlobalizeFixResetAttribute
#   def _reset_attribute name
#     old_value = record.attribute_was(name)
#     record.clear_attribute_changes([name])
#     record.send("#{name}=", old_value)
#   end
# end
#
# Globalize::ActiveRecord::AdapterDirty.module_eval do
#   prepend GlobalizeFixResetAttribute
# end