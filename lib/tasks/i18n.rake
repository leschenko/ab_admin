desc 'Prepare model and attribute translations of AR models'

namespace :i18n do
  task models: :environment do
    AbAdmin::I18nTools::ModelTranslator.i18n_models!
  end
end