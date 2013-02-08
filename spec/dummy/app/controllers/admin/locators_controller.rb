class ::Admin::LocatorsController < ::Admin::BaseController
  authorize_resource #:class => Locator

  #defaults #:resource_class => Locator

  before_filter :find_files, :only => [:show, :edit, :update]
  before_filter :find_file, :only => [:edit, :update]

  def edit
    @locale_hash = YAML.load_file(@file)
  end


  #def update
  #  if @i18n_back.set_by_file(params[:id].to_i, params[:locale_hash])
  #    flash[:notice] = I18n.t('flash.admin.locators.updated')
  #    redirect_to admin_locators_path
  #  else
  #    flash[:error] = I18n.t('flash.admin.locators.update_error')
  #    redirect_to edit_admin_locator_path(:id => params[:id])
  #  end
  #end
  #
  #def prepare
  #  @i18n_back = Utils::I18none::Translator.prepare_from_env
  #  if @i18n_back.message
  #    flash[:error] = @i18n_back.message
  #  else
  #    flash[:notice] = I18n.t('flash.admin.locators.prepared')
  #  end
  #  redirect_to collection_path
  #end

  def reload
    I18n.reload!
    flash[:notice] = I18n.t('flash.admin.locators.restart')
    redirect_to collection_path
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
    @files = Locator.instance.files
  end

  def find_file
    @file = @files.detect{|path| File.basename(path) == params[:filename]}
    raise "File #{params[:filename]} not found" unless @file
  end

  def resource
    Locator.instance
  end
end
