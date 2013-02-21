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
            if resource.is_a?(User) && resource.moderator?
              admin_root_path
            else
              super
            end
      end
    end

    class PasswordsController < ::Devise::PasswordsController
      include ::AbAdmin::Devise::Controller
    end

  end
end
