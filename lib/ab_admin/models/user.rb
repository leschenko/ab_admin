module AbAdmin
  module Models
    module User
      extend ActiveSupport::Concern

      included do
        has_one :avatar, as: :assetable, dependent: :destroy, autosave: true

        scope :managers, -> { where(user_role_id: [::UserRoleType.admin.id, ::UserRoleType.moderator.id]) }
        scope :active, -> { where(locked_at: nil) }
        scope :admin, -> { includes(:avatar) }

        after_initialize :init
        before_validation :generate_login
        before_validation :set_default_role, unless: :user_role_id?

        validate :check_role

        enumerated_attribute :user_role_type, id_attribute: :user_role_id, class: ::UserRoleType
      end

      def name
        full_name.strip.presence || email
      end

      def full_name
        [first_name.presence, last_name.presence].compact.join(' ')
      end

      def suspend!
        update_attribute(:locked_at, Time.now.utc)
      end

      def activate!
        confirm unless confirmed?
        unlock_access! if access_locked?
      end

      def active?
        active_for_authentication?
      end

      def generate_password!
        raw_password = AbAdmin.test_env? ? '654321' : AbAdmin.friendly_token
        self.password = self.password_confirmation = raw_password
        self.save(validate: false)
        raw_password
      end

      def admin_access?
        moderator?
      end

      def default?
        has_role?(:default)
      end

      def redactor?
        has_role?(:redactor)
      end

      def moderator?
        has_role?(:admin) || has_role?(:moderator)
      end

      def admin?
        has_role?(:admin)
      end

      def has_role?(role_name)
        user_role_type.code == role_name
      end

      def set_default_role
        self.user_role_id ||= ::UserRoleType.default.id
      end

      protected

      def generate_login
        self.login ||= begin
          unless email.blank?
            tmp_login = email.split('@').first
            tmp_login.parameterize.downcase.gsub(/[^A-Za-z0-9-]+/, '-').gsub(/-+/, '-')
          end
        end
      end

      def check_role
        errors.add(:user_role_id, :invalid) unless ::UserRoleType.valid?(user_role_id)
      end

    end
  end
end