module AbAdmin
  module Concerns
    module Validations
      class UniqTranslationValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          ::I18n.available_locales.each do |l|
            next if record.read_attribute(attribute, :locale => l).blank?
            records_scope = record.class.const_get(:Translation).where("#{record.class.model_name.foreign_key} != #{record.id || 0}")
            same = records_scope.where(:name => record.read_attribute(attribute, :locale => l), :locale => l.to_s).exists?
            record.errors.add("#{attribute}_#{l}", :taken) if same
          end
        end
      end

      class AssetValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          if Array(record.fileupload_asset(attribute)).all?{|a| a.new_record? }
            record.errors.add(attribute, :blank)
          end
        end
      end
    end
  end
end