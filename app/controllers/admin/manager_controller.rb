class ::Admin::ManagerController < ::Admin::BaseController
  include AbAdmin::Utils::EvalHelpers
  include AbAdmin::Controllers::Tree

  prepend_before_filter :manager

  load_and_authorize_resource

  helper_method :manager, :admin_partial_name, :history_resource_path

  def custom_action
    custom_action = manager.custom_action_for(params[:custom_action], self)
    if custom_action.options[:method] && custom_action.options[:method] != request.method_symbol
      raise ActionController::RoutingError.new("AbAdmin custom action for #{params[:custom_action]} not found")
    end
    instance_exec(&custom_action.data)
  end

  protected

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

  def apply_batch_action(item, batch_action)
    call_method_or_proc_on item, manager.batch_action_list.detect{|a| a.name == batch_action }.data, exec: false
    track_action("batch_#{batch_action}", item) if settings[:history]
  end

  def allow_batch_action?(batch_action)
    manager.batch_action_list.detect { |a| a.name == batch_action }
  end

  def batch_action_list
    manager.batch_action_list
  end

  def settings
    super.merge(manager.custom_settings || {})
  end

  def export_options
    manager.export.render_options
  end

  def manager
    @manager ||= begin
      manager_instance = "AbAdmin#{resource_class.name}".constantize.instance
      unless manager_instance.allow_action?(action_name)
        raise ActionController::RoutingError.new("AbAdmin action #{action_name} for #{resource_class.name} not found")
      end
      manager_instance
    rescue NameError => e
      raise ActionController::RoutingError.new("AbAdmin manager_model for #{resource_class.name} not found (#{e.message})")
    end
  end

  def resource_class
    @model ||= begin
      params[:model_name].classify.constantize
    rescue NameError => e
      raise ActionController::RoutingError.new("AbAdmin model #{params[:model_name]} not found (#{e.message})")
    end
  end

  def preview_resource_path(item)
    return unless manager.preview_path
    manager.preview_path.is_a?(Proc) ? manager.preview_path.bind(self).call(item) : send(manager.preview_path, item)
  end

  def admin_partial_name(builder)
    builder.partial ||= begin
      #if template_exists?(builder.partial_name, "admin/#{resource_collection_name}", true)
      if Dir[Rails.root.join("app/views/admin/#{resource_collection_name}/_#{builder.partial_name}.html.*")].present?
        "admin/#{resource_collection_name}/#{builder.partial_name}"
      end
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
