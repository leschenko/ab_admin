class ::Admin::ManagerController < ::Admin::BaseController
  prepend_before_filter :manager_model

  load_and_authorize_resource

  #has_scope :visible
  #has_scope :un_visible

  protected

  def manager_model
    @manager_model ||= begin
      "AbAdmin#{resource_class.name}".constantize
    rescue NameError
      raise ActionController::RoutingError.new("AbAdmin manager_model #{params[:model_name]} not found")
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
