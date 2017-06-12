class Admin::BaseController < ::InheritedResources::Base
  use Rack::Pjax, only: :index

  layout :set_layout

  include AbAdmin::Controllers::Fv
  include AbAdmin::Controllers::Callbacks

  define_admin_callbacks :save, :create

  before_action :authenticate_user!, :require_require_admin_access, :set_user_vars
  before_action :add_breadcrumbs, :set_title, unless: :xhr?

  class_attribute :export_builder, :batch_action_list, :button_scopes, instance_reader: false, instance_writer: false

  defaults finder: :friendly_find

  has_scope :by_ids, type: :array

  helper_method :admin?, :moderator?

  helper_method :button_scopes, :collection_action?, :action_items, :resource_action_items,
                :preview_resource_path, :get_subject, :settings, :batch_action_list, :tree_node_renderer,
                :normalized_index_views, :current_index_view, :pjax?, :xhr?, :max_per_page, :params_for_links

  rescue_from ::CanCan::AccessDenied, with: :render_unauthorized

  def index
    super do |format|
      format.js { render layout: false }
      format.csv do
        authorize! :export, resource_class
        doc = AbAdmin::Utils::CsvDocument.new(collection, export_options)
        send_data(doc.render, filename: doc.filename, type: Mime[:csv], disposition: 'attachment')
      end
      if Mime[:xlsx]
        format.xlsx do
          authorize! :export, resource_class
          doc = AbAdmin::Utils::XlsDocument.new(collection, export_options)
          send_data(doc.render, filename: doc.filename, type: Mime[:xlsx], disposition: 'attachment')
        end
      end
    end
  end

  def create
    create! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      success.js { render layout: false }
      failure.js { render :new, layout: false }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to redirect_to_on_success }
      failure.html { render :edit }
      success.js { render layout: false }
      failure.js { render :edit, layout: false }
      unless respond_to_format?(:json)
        success.json { head :no_content }
        failure.json { head :unprocessable }
      end
    end
  end

  def destroy
    destroy! do
      track_action! if settings[:history]
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
    raise 'No ids specified for batch action' unless params[:by_ids].present?
    batch_action = params[:batch_action].to_sym
    if allow_batch_action?(batch_action) && collection.all?{|item| can?(batch_action, item) }
      if batch_action.to_s.end_with?('_collection')
        count = collection.size
        resource_class.public_send(batch_action, collection, *[params[:batch_params]].compact)
        if settings[:history]
          if Object.const_defined?('ActiveRecord::Import') && Track.respond_to?(:import)
            tracks = collection.map { |item| track_action("batch_#{batch_action}", item) }
            Track.import_from_batch_collection_action(tracks)
          else
            collection.each { |item| track_action!("batch_#{batch_action}", item) }
          end
        end
      else
        count = collection.inject(0) { |c, item| apply_batch_action(item, batch_action, *[params[:batch_params]].compact) ? c + 1 : c }
      end
      batch_action_name = I18n.t("admin.actions.batch_#{batch_action}.title", default: batch_action.to_s.humanize)
      flash[:success] = I18n.t('admin.batch_actions.status', count: count, action: batch_action_name)
    else
      raise CanCan::AccessDenied
    end
    redirect_to_back_or_root
  end

  protected

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
    options.update instance_exec(&settings[:default_url_options]) if settings[:default_url_options]
    options
  end

  def apply_batch_action(item, batch_action, *batch_params)
    success = item.send(batch_action, *batch_params)
    track_action!("batch_#{batch_action}", item) if settings[:history]
    success
  end

  def allow_batch_action?(batch_action)
    batch_action_list.detect { |a| a.name == batch_action }
  end

  def redirect_to_back_or_root
    redirect_back fallback_location: admin_root_path
  end

  def track_action(key=nil, item=nil)
    (item || resource).track(key: key || action_name, user: current_user)
  end

  def track_action!(*args)
    track_action(*args).save!
  end

  def batch_action_list
    self.class.batch_action_list ||= begin
      resource_class.batch_actions.map do |a|
        opts = a == :destroy ? {confirm: I18n.t('admin.delete_confirmation')} : {}
        if a.is_a?(Hash)
          opts.merge!(a.except(:name))
          a = a[:name]
        end
        AbAdmin::Config::BatchAction.new(a, opts)
      end
    end
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
    track_action if settings[:history]
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

  def preview_resource_path(item)
    nil
  end

  def settings
    {
        index_view: 'table',
        sidebar: collection_action?,
        well: (collection_action? || %w(show history).include?(action_name)),
        search: true,
        batch: true,
        hotkeys: true,
        list_dblclick: true
    }
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

  def self.scope(name, options={})
    has_scope name, options.without(:badge)
    options[:badge] = {} if options[:badge] && !options[:badge].is_a?(Hash)
    self.button_scopes ||= []
    self.button_scopes << [name, options]
  end

  def button_scopes
    self.class.button_scopes ||= self.class.scopes_configuration.except(:by_ids).find_all{|_, s| s[:type] == :boolean }
    self.class.button_scopes.to_h
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

  def search_collection
    query = params[:q].try!{|q| q.permit!.to_h } || {}
    nested = resource_class.respond_to?(:acts_as_nested_set_options) && current_index_view == 'tree'
    query[:s] ||= settings[:default_order] || ('id desc' unless nested)
    @search = with_scopes(end_of_association_chain.accessible_by(current_ability).admin).ransack(query.no_blank)
    @search.result(distinct: @search.object.joins_values.present?)
  end

  def with_scopes(relation)
    relation
  end

  def collection
    @collection ||= begin
      result = search_collection
      result = result.paginate(page: params[:page], per_page: per_page, large: true) if action_name != 'batch' && !settings[:skip_pagination]
      result
    end
  end

  def per_page
    request_per_page = (params[:per_page].presence || cookies[:pp].presence).to_i.nonzero?
    params[:per_page] = [request_per_page || AbAdmin.view_default_per_page[current_index_view.to_sym], max_per_page].min
  end

  def max_per_page
    settings[:max_per_page] || AbAdmin.max_per_page
  end

  def set_layout
    pjax? ? false : 'admin/application'
  end

  def normalized_index_views
    Array(settings[:index_view])
  end

  def current_index_view
    index_view = params[:index_view].presence || cookies[:iv].presence
    if index_view && normalized_index_views.include?(index_view)
      cookies[:iv] = index_view
      index_view
    else
      normalized_index_views.first
    end
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
    fv.hotkeys = settings[:hotkeys]
    fv.list_dblclick = settings[:list_dblclick]
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
    user_signed_in? && current_user.moderator?
  end

  def admin?
    user_signed_in? && current_user.admin?
  end

  def require_require_admin_access
    raise CanCan::AccessDenied unless current_user.admin_access?
  end

  def require_moderator
    raise CanCan::AccessDenied unless moderator?
  end

  def require_admin
    raise CanCan::AccessDenied unless admin?
  end

  def bind_current_user(*)
    resource.user_id = current_user.id if !settings[:skip_bind_current_user] && resource.respond_to?(:user_id)
  end

  def bind_current_updater(*)
    resource.updater_id = current_user.id if !settings[:skip_bind_current_updater] && resource.respond_to?(:updater_id)
  end

  def get_subject
    params[:id] ? resource : resource_class
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

  def default_serializer_options
    if resource_class
      {root: resource_class.model_name.plural}
    else
      {root: false}
    end
  end
end
