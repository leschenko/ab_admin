# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :lockable, #:timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable,
         :encryptable, :encryptor => :sha512

  attr_accessible :password, :password_confirmation, :email, :remember_me,
                  :login, :first_name, :last_name, :patronymic, :phone, :skype, :web_site, :address, :birthday,
                  :time_zone, :locale, :bg_color


  attr_accessible :user_role_id, :trust_state, :as => :admin

  enumerated_attribute :user_role_type, :id_attribute => :user_role_id, :class => ::UserRoleType
  enumerated_attribute :trust_state_type, :id_attribute => :trust_state, :class => ::UserState

  include AbAdmin::Concerns::AdminAddition

  has_one :avatar, :as => :assetable, :dependent => :destroy, :autosave => true

  scope :managers, where(:user_role_id => [::UserRoleType.admin.id, ::UserRoleType.moderator.id])
  scope :active, where(:trust_state => ::UserState.active.id)
  scope :admin, includes(:avatar)

  after_initialize :init
  before_validation :generate_login
  before_validation :set_default_role, :unless => :user_role_id?
  before_update proc { |r| r.touch }

  validate :check_role

  alias_attribute :name, :title

  def init
    if new_record?
      self.user_role_id = ::UserRoleType.default.id unless user_role_id_changed?
      self.trust_state = ::UserState.pending.id unless trust_state_changed?
    end
    self.locale ||= 'ru'
    self.time_zone ||= 'Kiev'
  end

  def generate_password!
    raw_password = Rails.env.test? ? '654321' : Devise.friendly_token[0..7]
    self.password = self.password_confirmation = raw_password
    self.save(:validate => false)
    raw_password
  end

  def title
    full_name.strip.presence || email
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

  def set_default_role
    self.user_role_type ||= ::UserRoleType.default
  end

  def generate_login
    self.login ||= begin
      unless email.blank?
        tmp_login = email.split('@').first
        tmp_login.parameterize.downcase.gsub(/[^A-Za-z0-9-]+/, '-').gsub(/-+/, '-')
      end
    end
  end

  def check_role
    errors.add(:user_role_id, :invalid) unless ::UserRoleType.legal?(user_role_id)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  login                    :string(20)
#  user_role_id             :integer          default(1)
#  trust_state              :integer          default(1)
#  first_name               :string(255)
#  last_name                :string(255)
#  patronymic               :string(255)
#  phone                    :string(255)
#  address                  :string(255)
#  birthday                 :date
#  account_id               :integer
#  email                    :string(255)
#  encrypted_password       :string(255)      default(""), not null
#  reset_password_token     :string(255)
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0)
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string(255)
#  last_sign_in_ip          :string(255)
#  password_salt            :string(255)
#  confirmation_token       :string(255)
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  unconfirmed_email        :string(255)
#  failed_attempts          :integer          default(0)
#  unlock_token             :string(255)
#  locked_at                :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  gender                   :integer          default(1)
#  company_id               :integer
#  country_id               :integer
#  region_id                :integer
#  time_zone                :string(50)
#  locale                   :string(10)
#  web_site                 :string(255)
#  lang                     :string(255)
#  is_visible               :boolean          default(TRUE), not null
#  user_id                  :integer
#  bg_color                 :string(255)      default("ffffff")
#  skype                    :string(255)
#  footmarks_count          :integer          default(0)
#  reviews_count            :integer          default(0)
#  slogan                   :text
#  description              :text
#  is_visible_birthday_year :boolean          default(FALSE), not null
#  is_visible_email         :boolean          default(TRUE), not null
#  is_visible_skype         :boolean          default(TRUE), not null
#  slug                     :string(255)      not null
#  profession_id            :integer
#  region_name              :string(255)
#  projects_count           :integer          default(0)
#  user_type_id             :integer          default(1)
#  lat                      :float
#  lon                      :float
#  zoom                     :integer          default(14)
#  is_visible_phone         :boolean          default(TRUE), not null
#  shop_id                  :integer
#  is_legal                 :boolean          default(FALSE), not null
#  welcome_at               :datetime
#  is_subscribed            :boolean          default(TRUE), not null
#  unsubscribe_token        :string(255)
#

