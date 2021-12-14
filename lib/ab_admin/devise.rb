require 'devise'

module AbAdmin
  module Devise
    def self.config
      {
        controllers: {
            sessions: 'ab_admin/devise/sessions',
            passwords: 'ab_admin/devise/passwords'
        }
      }
    end

    module Controller
      extend ::ActiveSupport::Concern
      included do
        layout 'admin/devise'
      end
    end

    class SessionsController < ::Devise::SessionsController
      include ::AbAdmin::Devise::Controller

      def after_sign_in_path_for(resource)
        stored_location_for(resource) ||
            if resource.is_a?(User) && resource.admin_access?
              admin_root_path
            else
              super
            end
      end

      protected

      def sign_in_params
        devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt]) if devise_mapping.try(:two_factor_authenticatable?)
        devise_parameter_sanitizer.sanitize(:sign_in)
      end
    end

    class PasswordsController < ::Devise::PasswordsController
      include ::AbAdmin::Devise::Controller
    end
  end
end
