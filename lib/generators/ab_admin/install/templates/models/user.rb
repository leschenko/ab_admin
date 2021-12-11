class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable

  include AbAdmin::Concerns::AdminAddition
  include AbAdmin::Models::User

  fileuploads :avatar

end
