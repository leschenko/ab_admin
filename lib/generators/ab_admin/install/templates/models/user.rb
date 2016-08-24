class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable,
         :encryptable, encryptor: :sha512

  attr_accessible :password, :password_confirmation, :email, :remember_me,
                  :login, :first_name, :last_name, :patronymic, :phone, :skype, :web_site, :address, :birthday,
                  :time_zone, :locale, :bg_color, :gender


  attr_accessible :user_role_id, as: :admin

  include AbAdmin::Concerns::AdminAddition
  include AbAdmin::Models::User

  fileuploads :avatar

  def init
    set_default_role
    self.locale ||= 'ru'
    self.time_zone ||= 'Kiev'
  end

  def password_required?
    return true if password.present?
    return false if persisted? && password.blank?
    super
  end
end
