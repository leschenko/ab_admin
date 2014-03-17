class Admin::AssetsController < ApplicationController
  before_action :find_klass, only: :sort
  before_action :find_asset, only: [:destroy, :main, :rotate, :crop]

  authorize_resource

  respond_to :json

  def create
    @asset = build_asset(params[:asset])
    @asset.guid = params[:guid]
    @asset.data = prepared_data
    @asset.user = current_user
    @asset.save!

    render json: @asset
  end

  def destroy
    @asset.destroy!
    head :ok
  end

  def sort
    params[:asset].each_with_index do |id, index|
      @klass.move_to(index, id)
    end
    head :ok
  end

  def batch_edit
    @assets = Asset.includes(:translations).find(params[:ids])
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

  def find_asset
    @asset = Asset.find(params[:id])
  end

  def find_klass
    @klass = params[:klass].blank? ? Asset : params[:klass].classify.constantize
  end

  def prepared_data
    params[:data].original_filename = "blob.#{params[:data].content_type.split('/').last}" if params[:data].original_filename == 'blob'
    params[:data]
  end

  def build_asset(asset_params)
    raise 'Can not build Asset without assetable_type' if params[:assetable_type].blank?

    assetable_klass = params[:assetable_type].constantize
    assoc = assetable_klass.reflect_on_association(params[:method].to_sym)
    if params[:assetable_id].to_i.zero?
      assoc_scope = assoc.scope ? assoc.klass.instance_exec(&assoc.scope) : assoc.klass
      assoc_scope.where(assetable_type: assetable_klass.name, assetable_id: 0).new(asset_params)
    else
      assetable = assetable_klass.find(params[:assetable_id])
      if assoc.collection?
        assetable.send(params[:method]).new(asset_params)
      else
        assetable.send("build_#{params[:method]}", asset_params)
      end
    end
  end

end
