class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :destroy, to: :delete

    @user = user

    if @user
      send(@user.user_role_type.code)
    else
      guest
    end
  end

  def guest
  end

  def default
    guest
  end

  def redactor
    default
  end

  def moderator
    default
    can :manage, Dashboard
    can [:read, :create], AdminComment
    can :destroy, AdminComment, user_id: @user.id
    cannot :destroy, User, id: @user.id
  end

  def admin
    can :manage, :all

    cannot :destroy, User, id: @user.id
  end
end
