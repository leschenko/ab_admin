module AbAdmin
  module Models
    module User
      extend ActiveSupport::Concern

      included do
        has_one :avatar, as: :assetable, dependent: :destroy, autosave: true

        scope :active, -> { where(locked_at: nil) }
        scope :admin, proc { includes(:avatar) }

        enumerated_attribute :user_role_type, id_attribute: :user_role_id, class: ::UserRoleType
        delegate *UserRoleType.codes.map{|code| "#{code}?" }, to: :user_role_type
      end

      def admin_menu_builder
      end

      def name
        full_name.strip.presence || email
      end

      def full_name
        [first_name.presence, last_name.presence].compact.join(' ')
      end

      def suspend!
        lock_access!
      end

      def activate!
        confirm if respond_to?(:confirm) && !confirmed?
        unlock_access! if respond_to?(:unlock_access!) && access_locked?
      end

      def active?
        active_for_authentication?
      end

      def admin_access?
        admin? || moderator?
      end

      def generate_password!
        raw_password = AbAdmin.test_env? ? '654321' : AbAdmin.friendly_token
        self.password = self.password_confirmation = raw_password
        self.save(validate: false)
        raw_password
      end

      def password_required?
        return true if password.present?
        return false if persisted? && password.blank?
        super
      end
    end
  end
end