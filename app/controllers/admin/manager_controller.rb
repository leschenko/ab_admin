#require 'active_support/dependencies'
load 'ab_admin/abstract_resource.rb'
load '/private/var/www/hub/ab_admin/lib/ab_admin/config/base.rb'
load '/private/var/www/hub/ab_admin/lib/ab_admin/views/admin_navigation_helpers.rb'

class ::Admin::ManagerController < ::Admin::BaseController
  prepend_before_filter :manager

  load_and_authorize_resource

  #has_scope :visible
  #has_scope :un_visible

  helper_method :manager

  protected

  def manager
    @manager ||= begin
      "AbAdmin#{resource_class.name}".constantize.instance
    #rescue NameError
    #  raise ActionController::RoutingError.new("AbAdmin manager_model for #{resource_class.name} not found")
    end
  end

  def resource_class
    @model ||= begin
      params[:model_name].singularize.classify.constantize
    rescue NameError
      raise ActionController::RoutingError.new("AbAdmin model #{params[:model_name]} not found")
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
