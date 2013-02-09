class Admin::AssetsController < ApplicationController
  before_filter :find_klass, :only => [:create, :sort]
  before_filter :find_asset, :only => [:destroy, :main, :rotate, :crop]

  respond_to :html, :xml

  authorize_resource

  def create
    @asset = @klass.new(params[:asset])

    @asset.assetable_type = params[:assetable_type]
    @asset.assetable_id = params[:assetable_id] || 0
    @asset.guid = params[:guid]
    @asset.data = params[:data]
    @asset.user = current_user
    @asset.save

    respond_with(@asset) do |format|
      format.html { head :ok }
      format.xml { render :xml => @asset.to_xml }
    end
  end

  def destroy
    @asset.destroy

    respond_with(@asset) do |format|
      format.html { head :ok }
      format.xml { render :xml => @asset.to_xml }
    end
  end

  def sort
    params[:asset].each_with_index do |id, index|
      @klass.move_to(index, id)
    end

    respond_with(@klass) do |format|
      format.html { head :ok }
    end
  end

  def rotate
    render :json => @asset.rotate!
  end

  def main
    render :json => @asset.main!
  end

  def crop
    render :json => @asset.crop!(params[:crop_attrs])
  end

  protected

  def find_assets
    assoc = params[:assetable_type].constantize.reflect_on_association(params[:assoc].to_sym)
    scope = assoc.klass.where(:assetable_type => params[:assetable_type], :is_main => !assoc.collection?)
    if params[:assetable_id].present?
      scope.where(:assetable_id => params[:assetable_id])
    elsif params[:guid].present?
      scope.where(:guid => params[:guid])
    else
      []
    end
  end

  def find_asset
    @asset = Asset.find(params[:id])
  end

  def find_klass
    @klass = params[:klass].blank? ? Asset : params[:klass].classify.constantize
  end
end
