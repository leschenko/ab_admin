module AbAdmin
  class Engine < ::Rails::Engine
    engine_name 'ab_admin'

    initializer 'ab_admin.assets_precompile', :group => :all do |app|
      app.config.assets.precompile += AbAdmin.assets
    end

    initializer 'ab_admin.setup' do
      ::Mime::Type.register 'application/vnd.ms-excel', :xls

      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send :include, AbAdmin::CarrierWave::Glue
        ActiveRecord::Base.send :include, AbAdmin::Utils::Mysql
        ActiveRecord::Base.send :include, AbAdmin::Concerns::DeepCloneable
        ActiveRecord::Base.send :include, AbAdmin::Concerns::Utilities
        ActiveRecord::Base.send :include, AbAdmin::Concerns::Silencer
        ActiveRecord::Base.send :extend, AbAdmin::Concerns::Silencer
        ActiveRecord::Base.send :include, AbAdmin::Concerns::Validations
        ActiveRecord::Base.send :include, AbAdmin::Concerns::Fileuploads
        ActiveRecord::Base.send :extend, EnumField::EnumeratedAttribute
      end

      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.send :include, AbAdmin::Mailers::Helpers
      end

      ActiveSupport.on_load :action_view do
        ActionController::Base.helper AbAdmin::Views::Helpers
        ActionController::Base.helper AbAdmin::Views::AdminHelpers
        ActionController::Base.helper AbAdmin::Views::AdminNavigationHelpers
        ActionController::Base.helper AbAdmin::Views::ManagerHelpers
      end
    end
  end
end
