class Admin::AdminCommentsController < Admin::BaseController
  load_and_authorize_resource

  helper_method :commentable

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

  private

  def collection
    if xhr?
      @collection = AdminComment.find_for_resource(commentable)
    else
      super
    end
  end

  def commentable
    @commentable ||= AdminComment.find_resource(params[:resource_type], params[:resource_id])
  end

  def permitted_params
    params[:admin_comment].try!(:permit, :body, :resource_id, :resource_type, *AbAdmin.default_permitted_params)
  end
end
