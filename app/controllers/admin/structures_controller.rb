class Admin::StructuresController < Admin::BaseController
  include AbAdmin::Controllers::Tree

  load_and_authorize_resource

  protected

  def resource_action_items
    edit_structure = AbAdmin::Config::ActionItem.new({}) { |r| link_to icon('wrench', true), edit_resource_path(r), class: 'btn btn-warning' }
    edit_static_page = AbAdmin::Config::ActionItem.new({}) do |r|
      link_to(icon('pencil', true), edit_structure_record_path(r), class: 'btn btn-primary') if r.structure_type.static_page? || r.structure_type.main?
    end
    [edit_static_page, edit_structure, :destroy, :show]
  end

  def tree_node_renderer
    @tree_node_renderer ||= lambda { |r| link_to r.admin_title, edit_structure_record_path(r), class: 'tree-item_link' }
  end

  def settings
    {index_view: 'tree', default_order: 'lft'}
  end

  def permitted_params
    attrs = [:structure_type_id, :position_type_id, :parent_id, :title, :redirect_url, :is_visible,
             :structure_type, :position_type,
             *Structure.simple_slug_columns,
             *AbAdmin.default_permitted_params,
             *Structure.all_translated_attribute_names, header_attributes: [:id, *Header.all_translated_attribute_names]]
    params[:structure].try!(:permit, *attrs)
  end
end
