class Admin::BaseController < ::InheritedResources::Base
  use Rack::Pjax, only: :index

  layout :set_layout

  include AbAdmin::Controllers::Fv
  include AbAdmin::Controllers::Callbacks

  define_admin_callbacks :save, :create

  before_action :authenticate_user!, :require_admin_access, :build_settings, :set_user_vars
  before_action :add_breadcrumbs, :set_title, unless: :xhr?
  before_action :preflight_batch_action, only: :batch

  class_attribute :export_builder, :batch_actions, :button_scopes, instance_reader: true, instance_writer: false
  self.button_scopes = []
  self.batch_actions = [AbAdmin::Config::BatchAction.new(:destroy, confirm: I18n.t('admin.delete_confirmation'))]

  defaults finder: :friendly_find

  helper_method :admin?, :moderator?

  attr_reader :settings
  helper_method :button_scopes, :collection_action?, :action_items, :resource_action_items, :query_params,
                :settings, :batch_actions, :tree_node_renderer,
                :pjax?, :xhr?, :params_for_links, :resource_list_id, :ransack_collection, :search_collection

  rescue_from ::CanCan::AccessDenied, with: :render_unauthorized

  def index
    super do |format|
      format.js { render layout: false }
      if settings[:export]
        format.csv do
          authorize! :export, resource_class
          doc = AbAdmin::Utils::CsvDocument.new(collection, export_options)
          send_data(doc.render(self, locale: params[:locale]), filename: doc.filename, type: Mime[:csv], disposition: 'attachment')
        end
        if Mime[:xlsx]
          format.xlsx do
            authorize! :export, resource_class
            doc = AbAdmin::Utils::XlsDocument.new(collection, export_options)
            send_data(doc.render(self, locale: params[:locale]), filename: doc.filename, type: Mime[:xlsx], disposition: 'attachment')
          end
        end
      end
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      success.js { render layout: false }
      failure.js { render :new, layout: false }
      unless respond_to_format?(:json)
        success.json { head :no_content }
        failure.json { render json: {errors: resource.errors}, status: :unprocessable_entity }
      end
    end
  end

  def update
    resource.last_updated_timestamp = params[:last_updated_timestamp].to_i if settings[:safe_save] && !params[:_force_save] && params[:last_updated_timestamp]
    update! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      failure.html { render :edit }
      success.js { render layout: false }
      failure.js { render :edit, layout: false }
      unless respond_to_format?(:json)
        success.json { head :no_content }
        failure.json { render json: {errors: resource.errors}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy! do
      track_action! if @settings[:history]
      redirect_to_on_success
    end
  end

  def show
    show! do |format|
      format.js { render layout: false }
    end
  end

  def edit
    edit! do |format|
      format.js { render layout: false }
    end
  end

  def new
    new! do |format|
      format.js { render layout: false }
    end
  end

  def batch
    batch_action = batch_actions.detect{|a| a.name == params[:batch_action].to_sym }
    count = collection.inject(0) { |c, item| apply_batch_action(item, batch_action, *params[:batch_params].presence) ? c + 1 : c }
    flash[:success] = I18n.t('admin.batch_actions.status', count: count, action: batch_action.title)
    redirect_to_back_or_root
  end

  private

  def set_layout
    pjax? ? false : 'admin/application'
  end

  def preflight_batch_action
    batch_action = params[:batch_action].to_sym
    head :unprocessable_entity unless allow_batch_action?(batch_action) && params[:q].try!(:[], :id_in).present?
    raise CanCan::AccessDenied unless collection.all?{|item| can?(batch_action, item) }
  end

  def build_resource_params
    permitted_params || params[resource_class.model_name.param_key]
  end

  def params_for_links
    params.slice(:q, :s, :model_name, :per_page, :page).permit!
  end

  def respond_to_format?(format)
    self.class.mimes_for_respond_to[format]
  end

  def default_url_options
    options = {format: nil}
    options.update instance_exec(&AbAdmin.default_url_options) if AbAdmin.default_url_options
    options.update instance_exec(&@settings[:default_url_options]) if @settings && @settings[:default_url_options]
    options
  end

  def self.batch_action(name, options={}, &block)
    if options
      self.batch_actions << AbAdmin::Config::BatchAction.new(name.to_sym, options, &block)
    else
      self.batch_actions.reject!{|a| a.name == name.to_sym }
    end
  end

  def apply_batch_action(item, batch_action, *batch_params)
    success = batch_action.data.is_a?(Symbol) ? item.public_send(batch_action.data, *batch_params) : batch_action.data.call(item)
    track_action!("batch_#{batch_action.name}", item) if settings[:history]
    success
  end

  def allow_batch_action?(batch_action)
    batch_actions.detect { |a| a.name == batch_action }
  end

  def track_action(key=nil, item=nil)
    (item || resource).track(key: key || action_name, user: current_user)
  end

  def track_action!(*args)
    track_action(*args).save!
  end

  def self.inherited(base)
    super
    base.class_eval do
      before_create :bind_current_user
      before_save :bind_current_updater
      before_save :track_current_action
    end
  end

  def track_current_action(*)
    track_action if @settings[:history]
  end

  def flash_interpolation_options
    return {} if collection_action? || resource.errors.empty?
    {errors: resource.errors.full_messages.map { |m| "<br/> - #{m}" }.join.html_safe}
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

  def custom_settings
    {}
  end

  def build_settings
    @settings = AbAdmin.default_resource_settings.deep_dup.merge!(custom_settings)
    @settings[:index_views] = Array(@settings[:index_views]).map(&:to_sym)
    if collection_action?
      @settings[:current_index_view] = current_index_view
      @settings[:button_scopes] = @settings[:current_index_view] != :stats
      @settings[:per_page] ||= per_page
      @settings[:per_page_variants] ||= @settings[:per_page_variants].find_all{|n| n <= @settings[:max_per_page] }
      @settings[:sidebar] = true unless @settings.key?(:sidebar)
      @settings[:pagination] = @settings[:pagination_index_views].include?(@settings[:current_index_view])
      @settings[:order] = active_scopes.filter_map{|sc| sc.options[:default_order] }.first || @settings[:default_order] || ('id desc' unless @settings[:current_index_view] == :tree)
    end
    @settings[:well] = (collection_action? || %w(show history).include?(action_name)) && @settings[:current_index_view] != :tree unless @settings.key?(:well)
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
    @settings[:collection_actions].include?(action_name)
  end

  def add_breadcrumbs
    @breadcrumbs = []
    if parent?
      @breadcrumbs << {name: parent.class.model_name.human(count: 9), url: parent_collection_path}
      @breadcrumbs << {name: AbAdmin.display_name(parent), url: parent_path}
    end
    @breadcrumbs << {name: resource_class.model_name.human(count: 9), url: collection_path}
    if params[:id] && resource.persisted?
      @breadcrumbs << {name: AbAdmin.display_name(resource), url: resource_path}
    end
  end

  def set_title
    name_for_lookup = params[:custom_action] || action_name
    lookups = [:"admin.#{controller_name}.actions.#{name_for_lookup}.title",
               :"admin.#{controller_name}.actions.#{name_for_lookup}",
               :"admin.actions.#{name_for_lookup}.title",
               :"admin.actions.#{name_for_lookup}",
               name_for_lookup]
    @page_title ||= t(lookups.shift, default: lookups)
  end

  def parent_collection_path
    {action: :index, controller: "admin/#{parent.class.model_name.plural}"}
  end

  def tree_node_renderer
    @tree_node_renderer ||= lambda { |r| link_to AbAdmin.display_name(r), resource_path(r), class: 'tree-item_link' }
  end

  def collection
    return unless collection_action?
    @collection ||= begin
      result = search_collection
      result = result.paginate(page: params[:page], per_page: @settings[:per_page], large: true) if @settings[:pagination]
      result
    end
  end

  def search_collection
    return unless collection_action?
    @search_collection ||= with_scopes(ransack_collection.result(distinct: ransack_collection.object.joins_values.present?)).admin(current_user)
  end

  def ransack_collection
    return unless collection_action?
    @ransack_collection ||= end_of_association_chain.accessible_by(current_ability).ransack(query_params)
  end

  def query_params
    query = params[:q].try! {|q| q.permit!.to_h} || {}
    query[:s] ||= @settings[:order]
    query.reject_blank
  end

  def self.scope(name, options={}, &block)
    self.button_scopes << ::AbAdmin::Config::Scope.new(name, options, &block)
  end

  def active_scopes
    button_scopes.find_all{|scope| params[scope.name].present? }
  end

  def with_scopes(relation)
    active_scopes.inject(relation) { |result, scope| scope.apply(self, result) }
  end

  def redirect_to_back_or_root
    redirect_back fallback_location: admin_root_path, turbolinks: false
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
      new_resource_path(return_to: params[:return_to])
    elsif params[:_add_edit]
      edit_resource_path(resource, return_to: params[:return_to])
    elsif params[:_save_and_show]
      resource_path(resource, return_to: params[:return_to])
    elsif params[:_add_edit_next] || params[:_add_edit_prev]
      rec = resource.next_prev_by_url(end_of_association_chain.accessible_by(current_ability).unscoped.base, params[:return_to], !!params[:_add_edit_prev])
      if rec
        edit_resource_path(rec, return_to: params[:return_to])
      else
        back_or_collection
      end
    else
      back_or_collection
    end
  end

  def set_user_vars
    I18n.locale = AbAdmin.locale
    fv.locale = I18n.locale
    fv.bg_color = current_user.bg_color
    fv.admin = admin?
    fv.hotkeys = @settings[:hotkeys]
    fv.list_dblclick = @settings[:list_dblclick]
    fv.env = Rails.env
    if resource_class.respond_to?(:model_name)
      fv.resource_plural = resource_class.model_name.plural
      fv.resource_singular = resource_class.model_name.singular
    end
    if AbAdmin.test_env?
      fv.test = true
      AbAdmin.test_settings.each { |k, v| fv[k] = v }
    end
  end

  def pjax?
    request.headers['X-PJAX']
  end

  def xhr?
    request.xhr?
  end

  def moderator?
    current_user.try!(:moderator?)
  end

  def admin?
    current_user.try!(:admin?)
  end

  def require_admin_access
    raise CanCan::AccessDenied unless current_user.admin_access?
  end

  def bind_current_user(*)
    resource.user_id = current_user.id if !@settings[:skip_bind_current_user] && resource.respond_to?(:user_id)
  end

  def bind_current_updater(*)
    resource.updater_id = current_user.id if !@settings[:skip_bind_current_updater] && resource.respond_to?(:updater_id)
  end

  def render_unauthorized(exception)
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}, user: #{current_user.try(:id)}"

    if pjax?
      render partial: 'admin/shared/flash', locals: {flash: {alert: exception.message}}
    elsif request.format.try(:html?)
      redirect_to (current_user.try(:admin_access?) ? admin_root_path : root_path), alert: exception.message
    else
      head :unauthorized
    end
  end

  def resource_list_id
    "list_#{resource_instance_name}_#{resource.id}"
  end

  def per_page
    request_per_page = (params[:per_page].presence || cookies[:pp].presence).to_i.nonzero?
    params[:per_page] = [request_per_page || @settings[:view_default_per_page][@settings[:current_index_view]], @settings[:max_per_page]].min
  end

  def current_index_view
    index_view = params[:index_view].presence.try!(:to_sym)
    @settings[:index_views].include?(index_view) ? index_view : @settings[:index_views].first
  end
end
