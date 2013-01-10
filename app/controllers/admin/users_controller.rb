class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  has_scope :social

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

  def index_actions
    [:edit, :destroy, :show, :preview, :activate, :suspend]
  end

  def build_resource
    super
    resource.skip_confirmation!
    resource
  end

end
