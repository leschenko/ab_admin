class Admin::AdminCommentsController < Admin::BaseController
  load_and_authorize_resource

  before_create do |comment|
    comment.set_author(current_user)
    comment.user_id = comment.resource.user_id if comment.resource.respond_to?(:user_id)
  end

  def create
    create! do |format|
      format.js {}
    end
  end

  def destroy
    destroy! do |format|
      format.js {}
    end
  end

end
