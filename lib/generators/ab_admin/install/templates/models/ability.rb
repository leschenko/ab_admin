class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :destroy, to: :delete

    @user = user

    if @user
      case @user.user_role_type.id
        when ::UserRoleType.default.id then default
        when ::UserRoleType.redactor.id then redactor
        when ::UserRoleType.moderator.id then moderator
        when ::UserRoleType.admin.id then admin
      end
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
