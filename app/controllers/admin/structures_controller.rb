class Admin::StructuresController < Admin::BaseController
  include AbAdmin::Controllers::Tree

  load_and_authorize_resource

  #has_scope :visible
  #has_scope :un_visible

  protected

  def tree_node_renderer
    @tree_node_renderer ||= lambda { |r| link_to r.title, edit_structure_record_path(r), :class => 'tree-item_link' }
  end

  def settings
    {:index_view => 'tree'}
  end
end
