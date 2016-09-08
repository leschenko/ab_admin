class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def activate
    resource.activate!
    redirect_back fallback_location: admin_users_url
  end

  def suspend
    resource.suspend!
    redirect_back fallback_location: admin_users_url
  end

  private

  export do
    field :login
    field :email
    field :first_name
    field :last_name
    field :patronymic
    field(:trust_state) {|r| r.trust_state_type.try(:title) }
    field(:user_role_id) {|r| r.user_role_type.try(:title) }
    field :phone
    field :skype
    field :birthday
    field :locale
    field :time_zone
    #field(:gender) {|r| r.gender_type.try(:title) }
    field :sign_in_count
    field :current_sign_in_at
    field :last_sign_in_at
    field :current_sign_in_ip
    field :last_sign_in_ip
    field :confirmed_at
    field :created_at
  end

  def resource_action_items
    [:edit, :destroy, :show, :preview, :activate, :suspend]
  end

  def build_resource
    super
    resource.skip_confirmation!
    resource
  end

  def permitted_params
    attrs = [:password, :password_confirmation, :email, :remember_me,
             :login, :first_name, :last_name, :patronymic, :phone, :skype, :web_site, :address, :birthday,
             :time_zone, :locale, :bg_color, :gender]
    attrs << [:user_role_id] if admin?
    params.permit(user: attrs)
  end
end
