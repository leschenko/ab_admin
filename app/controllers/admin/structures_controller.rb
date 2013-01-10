class Admin::StructuresController < Admin::BaseController
  include TheSortableTreeController::ReversedRebuild

  load_and_authorize_resource

  has_scope :visible
  has_scope :un_visible

  protected

  def settings
    {:index_view => 'tree'}
  end
end
