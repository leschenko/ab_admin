class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :lockable, #:timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable,
         :encryptable, :encryptor => :sha512

  attr_accessible :password, :password_confirmation, :email, :remember_me,
                  :login, :first_name, :last_name, :patronymic, :phone, :skype, :web_site, :address, :birthday,
                  :time_zone, :locale, :bg_color


  attr_accessible :user_role_id, :trust_state, :as => :admin


  include AbAdmin::Concerns::AdminAddition
  include AbAdmin::Models::User

  fileuploads :avatar

  def init
    set_default_role
    self.trust_state ||= ::UserState.pending.id
    self.locale ||= 'ru'
    self.time_zone ||= 'Kiev'
  end

end
