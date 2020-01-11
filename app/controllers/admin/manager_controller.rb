class ::Admin::ManagerController < ::Admin::BaseController
  include AbAdmin::Utils::EvalHelpers
  include AbAdmin::Controllers::Tree

  prepend_before_action :manager

  load_and_authorize_resource

  helper_method :manager, :admin_partial_name, :history_resource_path, :fetch_admin_template

  def custom_action
    custom_action = manager.custom_action_for(params[:custom_action], self)
    if custom_action.options[:method] && custom_action.options[:method] != request.method_symbol
      raise ActionController::RoutingError.new("AbAdmin custom action for #{params[:custom_action]} not found")
    end
    instance_exec(&custom_action.data)
  end

  protected

  def button_scopes
    manager.scopes.map{|scope| [scope.name, scope.options] }
  end

  def with_scopes(relation)
    scopes_to_apply.inject(relation) { |result, scope| scope.apply(result, params) }
  end

  def scopes_to_apply
    manager.scopes.find_all{|scope| params[scope.name].present? }
  end

  def begin_of_association_chain
    parent
  end

  def parent
    return @parent if defined?(@parent)
    @parent = begin
      return if !params[:parent_resource] && !params[:parent_resource_id]
      assoc_name, r_id = params[:parent_resource].singularize.to_sym, params[:parent_resource_id]
      parent_config = manager.parent_resources.detect { |conf| conf.name == assoc_name }
      return unless parent_config
      assoc = resource_class.reflect_on_association(parent_config.name)
      return unless assoc
      assoc.klass.find(r_id)
    end
  end

  def parent?
    !!parent
  end

  def parent_type
    parent.class.name.underscore.to_sym
  end

  def parent_class
    parent.class
  end

  def parent_path
    "/admin/#{parent_class.model_name.plural}/#{parent.id}"
  end

  def parent_collection_path
    "/admin/#{parent_class.model_name.plural}"
  end

  def tree_node_renderer
    manager.tree_node_renderer || super
  end

  def resource_action_items
    manager.resource_action_items
  end

  def action_items
    for_resource = params[:id].present? && resource.persisted?
    manager.default_action_items_for(action_name.to_sym, for_resource) + manager.action_items_for(action_name.to_sym)
  end

  def apply_batch_action(item, batch_action, *batch_params)
    data = manager.batch_action_list.detect{|a| a.name == batch_action }.data
    success = call_method_or_proc_on item,  data, exec: false, attrs: batch_params
    track_action!("batch_#{batch_action}", item) if settings[:history]
    success
  end

  def allow_batch_action?(batch_action)
    manager.batch_action_list.detect { |a| a.name == batch_action }
  end

  def batch_action_list
    manager.batch_action_list
  end

  def custom_settings
    manager.custom_settings || {}
  end

  def export_options
    manager.export.render_options
  end

  def manager
    @manager ||= begin
      manager_class_name = "AbAdmin#{resource_class.name}"
      manager_instance = manager_class_name.constantize.instance
      unless manager_instance.allow_action?(action_name)
        raise ActionController::RoutingError.new("AbAdmin action #{action_name} for #{resource_class.name} not found")
      end
      manager_instance
    rescue NameError => e
      if e.message.include?(manager_class_name)
        raise ActionController::RoutingError.new("AbAdmin manager_model for #{resource_class.name} not found (#{e.message})")
      else
        raise
      end
    end
  end

  def resource_class
    @model ||= begin
      params[:model_name].classify.constantize
    rescue NameError => e
      raise ActionController::RoutingError.new("AbAdmin model #{params[:model_name]} not found (#{e.message})")
    end
  end

  def permitted_params
    attrs = Array(manager.permitted_params.is_a?(Proc) ? instance_exec(&manager.permitted_params) : manager.permitted_params)
    resource_params = params[resource_class.model_name.param_key]
    return {} unless resource_params
    if attrs.first == :all
      resource_params.permit!
    else
      attrs = attrs + AbAdmin.default_permitted_params
      resource_params.permit(*attrs)
    end
  end

  def preview_resource_path(item)
    return unless manager.preview_path
    return if manager.preview_path[:options][:if] && !call_method_or_proc_on(item, manager.preview_path[:options][:if])
    I18n.with_locale I18n.default_locale do
      manager.preview_path[:value].is_a?(Proc) ? instance_exec(item, &manager.preview_path[:value]) : send(manager.preview_path[:value], item)
    end
  end

  def admin_partial_name(builder)
    builder.partial ||= begin
      #if template_exists?(builder.partial_name, "admin/#{resource_collection_name}", true)
      fetch_admin_template(builder.partial_name, true)
    end
  end

  def fetch_admin_template(template_name, partial=false)
    if Dir[Rails.root.join("app/views/admin/#{resource_collection_name}/#{'_' if partial}#{template_name}.html.*")].present?
      "admin/#{resource_collection_name}/#{template_name}"
    end
  end

  def resource_collection_name
    resource_class.model_name.plural
  end

  def resource_instance_name
    resource_class.model_name.singular
  end

  def collection_path(options={})
    admin_index_path(options.merge(model_name: resource_collection_name))
  end

  def collection_url(options={})
    admin_index_url(options.merge(model_name: resource_collection_name))
  end

  def new_resource_path(options={})
    admin_new_path(options.merge(model_name: resource_collection_name))
  end

  def resource_path(record=nil, options={})
    record ||= resource
    admin_show_path(options.merge(model_name: record.class.model_name.plural, id: record.id))
  end

  def edit_resource_path(record=nil, options={})
    record ||= resource
    admin_edit_path(options.merge(model_name: record.class.model_name.plural, id: record.id))
  end

  def history_resource_path(record=nil, options={})
    record ||= resource
    admin_history_path(options.merge(model_name: record.class.model_name.plural, id: record.id))
  end

  def self.cancan_resource_class
    AbAdmin::Controllers::CanCanManagerResource
  end
end
