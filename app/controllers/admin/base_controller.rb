class Admin::BaseController < ::InheritedResources::Base
  use Rack::Pjax, :only => :index

  layout :set_layout

  include AbAdmin::Controllers::Callbacks
  define_admin_callbacks :save, :create

  before_filter :authenticate_user!, :require_moderator
  before_filter :add_breadcrumbs, :set_title, :set_user_vars, :unless => :xhr?

  class_attribute :csv_builder

  has_scope :ids, :type => :array

  helper_method :admin?, :moderator?

  helper_method :button_scopes, :collection_action?, :action_items, :index_actions, :csv_builder,
                :preview_resource_path, :get_subject, :settings, :with_sidebar?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_root_path, :alert => exception.message
  end

  def index
    super do |format|
      format.csv do
        headers['Content-Type'] = 'text/csv; charset=utf-8'
        headers['Content-Disposition'] = %{attachment; filename="#{csv_filename}"}
      end
      format.js { render collection }
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      failure.html { render :edit }
    end
  end

  def destroy
    destroy! { redirect_to_on_success }
  end

  def batch
    raise 'No ids specified for batch action' unless params[:ids].present?
    batch_action = resource_class.batch_action(params[:batch_action])
    if collection.all?{|item| can?(batch_action, item) }
      count = collection.inject(0) { |c, item| apply_batch_action(item, batch_action) ? c + 1 : c }
      flash[:success] = "#{count} #{batch_action}"
    else
      flash[:failure] = 'You don\'t have permissions to perform this action'
    end
    redirect_to :back
  end

  def apply_batch_action(item, batch_action)
    item.send(batch_action)
  end
  
  def search
    collection
    render :index
  end

  protected

  def self.inherited(base)
    super
    base.class_eval do
      before_create :bind_current_user
    end
  end

  def interpolation_options
    return {} if collection_action? || resource.errors.empty?
    {:errors => resource.errors.full_messages.map { |m| "<br/> - #{m}" }.join.html_safe}
  end

  def self.csv(options={}, &block)
    self.csv_builder = ::AbAdmin::Utils::CSVBuilder.new(options, &block)
  end

  def csv_filename
    "#{resource_collection_name.to_s.gsub('_', '-')}-#{Time.now.strftime("%Y-%m-%d")}.csv"
  end

  def csv_builder
    self.class.csv_builder ||= ::AbAdmin::Utils::CSVBuilder.default_for_resource(resource_class)
  end

  def set_title
    lookups = [:"admin.#{controller_name}.actions.#{action_name}.title",
               :"admin.#{controller_name}.actions.#{action_name}",
               :"admin.actions.#{action_name}.title",
               :"admin.actions.#{action_name}"]
    @page_title ||= [resource_class.model_name.human(:count => 1), t(lookups.shift, :default => lookups)].join(' - ')
  end

  def preview_resource_path(item)
    nil
  end

  def settings
    {:index_view => 'table', :sidebar => true, :well => true, :search => true, :batch => true}
  end

  def action_items
    case action_name.to_sym
      when :new, :create
        [:new]
      when :show
        resource_action_items - [:show]
      when :edit, :update
        resource_action_items - [:edit]
      when :index
        [:new]
      else
        [:new]
    end
  end

  def resource_action_items
    links = [:new, :edit, :show, :destroy]
    links << :preview if preview_resource_path(resource)
    links
  end

  def index_actions
    [:edit, :destroy, :show, :preview]
  end

  def collection_action?
    %w(index search batch).include?(action_name)
  end

  def with_sidebar?
    collection_action? && settings[:sidebar]
  end

  def button_scopes
    @@button_scopes ||= begin
      res = {}
      self.class.scopes_configuration.except(:ids).each do |k, v|
        res[k] = v if v[:type] == :default
      end
      res
    end
  end

  def add_breadcrumbs
    @breadcrumbs = []
    if parent?
      @breadcrumbs << {:name => parent_class.model_name.human(:count => 9),
                       :url => {:action => :index, :controller => "admin/#{parent_class.model_name.plural}"}}
      @breadcrumbs << {:name => parent.title, :url => parent_path}
    end
    @breadcrumbs << {:name => resource_class.model_name.human(:count => 9), :url => collection_path}
    if params[:id]
      @breadcrumbs << {:name => resource.title, :url => resource_path}
    end
  end

  def search_collection
    params[:q] ||= {}
    params[:q][:s] ||= 'id desc'
    @search = end_of_association_chain.accessible_by(current_ability).admin.ransack(params[:q].no_blank)
    @search.result(:distinct => true)
  end

  def collection
    @collection ||= search_collection.paginate(:page => params[:page], :per_page => per_page, :large => true)
  end

  def per_page
    return params[:per_page] if params[:per_page].present?
    if settings[:index_view] == 'tree'
      params[:per_page] = 1000
    else
      params[:per_page] = cookies[:pp] || 50
    end
  end

  def set_layout
    request.headers['X-PJAX'] ? false : 'admin/application'
  end

  def back_or_collection
    if params[:return_to].present? && (params[:return_to] != request.fullpath)
      params[:return_to]
    else
      smart_collection_url
    end
  end

  def redirect_to_on_success
    if params[:_add_another]
      new_resource_path(:return_to => params[:return_to])
    elsif params[:_add_edit]
      edit_resource_path(resource, :return_to => params[:return_to])
    elsif params[:_add_edit_next] || params[:_add_edit_prev]
      rec = resource.next_prev_by_url(end_of_association_chain.accessible_by(current_ability).unscoped.base, params[:return_to], !!params[:_add_edit_prev])
      if rec
        edit_resource_path(rec, :return_to => params[:return_to])
      else
        back_or_collection
      end
    else
      back_or_collection
    end
  end

  def set_user_vars
    I18n.locale = Rails.application.config.i18n.default_locale
    gon.bg_color = current_user.bg_color
    gon.admin = admin?
  end

  def moderator?
    user_signed_in? && current_user.moderator?
  end

  def admin?
    user_signed_in? && current_user.admin?
  end

  def require_moderator
    raise CanCan::AccessDenied unless moderator?
  end

  def require_admin
    raise CanCan::AccessDenied unless admin?
  end

  def bind_current_user(*args)
    resource.user_id = current_user.id if resource.respond_to?(:user_id)
  end

  def xhr?
    request.xhr?
  end

  # roles logic
  def role_given?
    fetch_role
  end

  def as_role
    {:as => fetch_role}
  end

  def get_role
    return :admin if admin?
    nil
  end

  def fetch_role
    return @as_role if defined?(@as_role)
    @as_role = get_role
  end

  def get_subject
    params[:id] ? resource : resource_class
  end

end