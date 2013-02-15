class Admin::BaseController < ::InheritedResources::Base
  use Rack::Pjax, :only => :index

  layout :set_layout

  include AbAdmin::Controllers::Callbacks
  define_admin_callbacks :save, :create

  before_filter :authenticate_user!, :require_moderator
  before_filter :add_breadcrumbs, :set_title, :set_user_vars, :unless => :xhr?

  class_attribute :export_builder, :batch_action_list, :instance_reader => false, :instance_writer => false
  self.batch_action_list = [AbAdmin::Config::BatchAction.new(:destroy, :confirm => I18n.t('admin.delete_confirmation'))]

  has_scope :ids, :type => :array

  helper_method :admin?, :moderator?

  helper_method :button_scopes, :collection_action?, :action_items, :resource_action_items,
                :preview_resource_path, :get_subject, :settings, :batch_action_list, :tree_node_renderer

  respond_to :json, :only => [:index, :update]

  rescue_from ::CanCan::AccessDenied, :with => :render_unauthorized

  def index
    super do |format|
      format.js { render collection }
      format.csv do
        doc = AbAdmin::Utils::CsvDocument.new(collection, export_options)
        send_data(doc.render, :filename => doc.filename, :type => Mime::CSV, :disposition => 'attachment')
      end
      if defined?(Mime::XLSX)
        format.xls do
          doc = AbAdmin::Utils::XlsDocument.new(collection, export_options)
          send_data(doc.render, :filename => doc.filename, :type => Mime::XLSX, :disposition => 'attachment')
        end
      end
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      success.js { render :layout => false }
      failure.js { render :new, :layout => false }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      failure.html { render :edit }
      success.js { render :layout => false }
      failure.js { render :edit, :layout => false }
    end
  end

  def destroy
    destroy! { redirect_to_on_success }
  end

  def edit
    edit! do |format|
      format.js { render :layout => false }
    end
  end

  def new
    new! do |format|
      format.js { render :layout => false }
    end
  end

  def batch
    raise 'No ids specified for batch action' unless params[:ids].present?
    batch_action = params[:batch_action].to_sym
    if allow_batch_action?(batch_action) && collection.all?{|item| can?(batch_action, item) }
      count = collection.inject(0) { |c, item| apply_batch_action(item, batch_action) ? c + 1 : c }
      flash[:success] = I18n.t('admin.batch_actions.status', :count => count, :action => I18n.t("admin.actions.batch_#{batch_action}.title"))
    else
      raise CanCan::AccessDenied
    end
    redirect_to :back
  end

  def apply_batch_action(item, batch_action)
    item.send(batch_action)
  end

  def allow_batch_action?(batch_action)
    resource_class.batch_actions.include?(batch_action)
  end

  protected

  def batch_action_list
    self.class.batch_action_list
  end

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

  def self.export(options={}, &block)
    self.export_builder = ::AbAdmin::Config::Export.new(options, &block)
  end

  def export_builder
    self.class.export_builder ||= ::AbAdmin::Config::Export.default_for_model(resource_class)
  end

  def export_options
    export_builder.render_options
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
    {:index_view => 'table', :sidebar => collection_action?, :well => (collection_action? || action_name == 'show'),
     :search => true, :batch => true, :hotkeys => true}
  end

  def action_items
    case action_name.to_sym
      when :show
        [:new, :edit, :destroy, :preview]
      when :edit, :update
        [:new, :show, :destroy, :preview]
      else
        [:new]
    end
  end

  def resource_action_items
    [:edit, :destroy, :show, :preview]
  end

  def collection_action?
    %w(index search batch rebuild).include?(action_name)
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
      @breadcrumbs << {:name => AbAdmin.display_name(parent), :url => parent_path}
    end
    @breadcrumbs << {:name => resource_class.model_name.human(:count => 9), :url => collection_path}
    if params[:id]
      @breadcrumbs << {:name => AbAdmin.display_name(resource), :url => resource_path}
    end
  end

  def tree_node_renderer
    @tree_node_renderer ||= lambda { |r| link_to AbAdmin.display_name(r), resource_path(r), :class => 'tree-item_link' }
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
    gon.locale = I18n.locale
    gon.bg_color = current_user.bg_color
    gon.admin = admin?
    gon.test = Rails.env.test?
    gon.hotkeys = settings[:hotkeys]
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

  def render_unauthorized(exception)
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}, user: #{current_user.try(:id)}"

    respond_to do |format|
      format.html { redirect_to (moderator? ? admin_root_path : root_path), :alert => exception.message }
      format.any { head :unauthorized }
    end
  end

end