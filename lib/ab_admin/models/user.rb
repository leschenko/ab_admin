module AbAdmin
  module Models
    module User
      extend ActiveSupport::Concern

      included do
        has_one :avatar, as: :assetable, dependent: :destroy, autosave: true

        scope :managers, where(user_role_id: [::UserRoleType.admin.id, ::UserRoleType.moderator.id])
        scope :active, where(trust_state: ::UserState.active.id)
        scope :admin, includes(:avatar)

        after_initialize :init
        before_validation :generate_login
        before_validation :set_default_role, unless: :user_role_id?

        validate :check_role

        enumerated_attribute :user_role_type, id_attribute: :user_role_id, class: ::UserRoleType
        enumerated_attribute :trust_state_type, id_attribute: :trust_state, class: ::UserState
      end

      def set_default_role
        self.user_role_id ||= ::UserRoleType.default.id
      end

      def generate_password!
        raw_password = Rails.env.test? ? '654321' : ::Devise.friendly_token[0..7]
        self.password = self.password_confirmation = raw_password
        self.save(validate: false)
        raw_password
      end

      def name
        full_name.strip.presence || email
      end

      def full_name
        [first_name.presence, last_name.presence].compact.join(' ')
      end

      def activate
        self.trust_state = ::UserState.active.id
        self.locked_at = nil
      end

      def activate!
        confirm!
        activate
        save
      end

      def suspend!
        self.update_attribute(:trust_state, ::UserState.suspended.id)
      end

      def delete!
        self.update_attribute(:trust_state, ::UserState.deleted.id)
      end

      def unsuspend!
        self.update_attribute(:trust_state, ::UserState.active.id)
      end

      def deleted?
        trust_state == ::UserState.deleted.id
      end

      def moderator?
        has_role?(:admin) || has_role?(:moderator)
      end

      def admin_access?
        moderator?
      end

      def default?
        has_role?(:default)
      end

      def admin?
        has_role?(:admin)
      end

      def has_role?(role_name)
        user_role_type.code == role_name
      end

      def pending?
        trust_state == ::UserState.pending.id
      end

      def trusted?
        self.trust_state == ::UserState.active.id
      end

      def active_for_authentication?
        super && trusted?
      end

      def inactive_message
        trusted? ? super : :unconfirmed
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