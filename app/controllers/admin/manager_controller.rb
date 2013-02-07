#require 'active_support/dependencies'
load 'ab_admin/abstract_resource.rb'
load '/private/var/www/hub/ab_admin/lib/ab_admin/config/base.rb'
load '/private/var/www/hub/ab_admin/lib/ab_admin/views/admin_navigation_helpers.rb'
load '/private/var/www/hub/ab_admin/lib/ab_admin/views/admin_helpers.rb'



class ::Admin::ManagerController < ::Admin::BaseController
  include AbAdmin::Utils::EvalHelpers
  include AbAdmin::Controllers::Tree

  prepend_before_filter :manager

  load_and_authorize_resource

  #has_scope :visible
  #has_scope :un_visible

  helper_method :manager, :admin_partial_name

  protected

  def resource_action_items
    manager.resource_action_items
  end

  def action_items
    manager.default_action_items_for(action_name.to_sym, params[:id].present?) + manager.action_items_for(action_name.to_sym)
  end

  def apply_batch_action(item, batch_action)
    call_method_or_proc_on item, manager.batch_action_list.detect{|a| a.name == batch_action }.data, :exec => false
  end

  def allow_batch_action?(batch_action)
    manager.batch_action_list.detect { |a| a.name == batch_action }
  end

  def batch_action_list
    manager.batch_action_list
  end

  def settings
    manager.settings ||= super.merge(manager.custom_settings || {})
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
    rescue NameError
      raise ActionController::RoutingError.new("AbAdmin manager_model for #{resource_class.name} not found")
    end
  end

  def resource_class
    @model ||= begin
      params[:model_name].singularize.classify.constantize
    rescue NameError
      raise ActionController::RoutingError.new("AbAdmin model #{params[:model_name]} not found")
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
    admin_index_path(options.merge(:model_name => resource_collection_name))
  end

  def collection_url(options={})
    admin_index_url(options.merge(:model_name => resource_collection_name))
  end

  def new_resource_path(options={})
    admin_new_path(options.merge(:model_name => resource_collection_name))
  end

  def edit_resource_path(record=nil, options={})
    record ||= resource
    admin_edit_path(options.merge(:model_name => resource_collection_name, :id => record.id))
  end

  def resource_path(record=nil, options={})
    record ||= resource
    admin_show_path(options.merge(:model_name => resource_collection_name, :id => record.id))
  end

  def self.cancan_resource_class
    AbAdmin::Controllers::CanCanManagerResource
  end
end
