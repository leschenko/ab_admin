class Admin::AssetsController < ApplicationController
  before_filter :find_klass, only: [:create, :sort]
  before_filter :find_asset, only: [:destroy, :main, :rotate, :crop]

  authorize_resource

  def create
    @asset = @klass.new(params[:asset])

    @asset.assetable_type = params[:assetable_type]
    @asset.assetable_id = params[:assetable_id] || 0
    @asset.guid = params[:guid]
    @asset.data = params[:data]
    @asset.user = current_user
    @asset.save

    head :ok
  end

  def destroy
    @asset.destroy
    head :ok
  end

  def sort
    params[:asset].each_with_index do |id, index|
      @klass.move_to(index, id)
    end
    head :ok
  end

  def batch_edit
    @assets = Asset.find(params[:ids])
    render layout: false
  end

  def batch_update
    Asset.update(params[:data].keys, params[:data].values)
    head :ok
  end

  def rotate
    render json: @asset.rotate!
  end

  def main
    render json: @asset.main!
  end

  def crop
    render json: @asset.crop!(params[:geometry])
  end

  protected

  def find_assets
    assoc = params[:assetable_type].constantize.reflect_on_association(params[:assoc].to_sym)
    scope = assoc.klass.where(assetable_type: params[:assetable_type], is_main: !assoc.collection?)
    if params[:assetable_id].present?
      scope.where(assetable_id: params[:assetable_id])
    elsif params[:guid].present?
      scope.where(guid: params[:guid])
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
