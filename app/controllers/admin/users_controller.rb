class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def activate
    resource.confirm! unless resource.confirmed?
    resource.unsuspend!
    redirect_to :back
  end

  def suspend
    resource.suspend!
    redirect_to :back
  end

  private

  def resource_action_items
    [:edit, :destroy, :show, :preview, :activate, :suspend]
  end

  def build_resource
    super
    resource.skip_confirmation!
    resource
  end

end
