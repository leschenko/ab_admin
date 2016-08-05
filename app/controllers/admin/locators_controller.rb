class ::Admin::LocatorsController < ::Admin::BaseController
  authorize_resource

  before_action :find_files, only: [:show, :edit, :update]
  before_action :find_file, only: [:edit, :update]

  def edit
    @locale_hash = YAML.load_file(@file)
  end

  def update
    if Locator.save(@file, {params[:edit_locale_name] => params.require(:locale_hash).permit!.to_h})
      flash[:notice] = I18n.t('flash.admin.locators.updated')
      redirect_to admin_locators_path
    else
      flash[:error] = I18n.t('flash.admin.locators.update_error')
      redirect_to edit_admin_locators_path(filename: params[:filename])
    end
  end

  def prepare
    result = Locator.instance.prepare_files
    if !result
      flash[:error] = 'Failed to prepare locale files'
    elsif result[:message]
      flash[:error] = result[:message]
    else
      flash[:notice] = I18n.t('flash.admin.locators.prepared')
    end
    redirect_to admin_locators_path
  end

  def reload
    I18n.reload!
    Locator.reload_checker.expire if Locator.respond_to?(:reload_checker)
    flash[:notice] = I18n.t('flash.admin.locators.restart')
    redirect_to admin_locators_path
  end

  protected

  def collection
    []
  end

  def settings
    {}
  end

  def action_items
    []
  end

  def find_files
    @files = Locator.find_files
  end

  def find_file
    redirect_to(admin_locators_path) and return if params[:filename].blank?
    @file = @files.detect{|path| File.basename(path) == params[:filename]}
    raise "File #{params[:filename]} not found" unless @file
  end

  def resource
    Locator.instance
  end
end
