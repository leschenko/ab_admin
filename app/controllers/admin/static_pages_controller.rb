class Admin::StaticPagesController < Admin::BaseController
  load_and_authorize_resource

  defaults singleton: true, class_name: 'Structure'

  belongs_to :structure, finder: :friendly_find

  private

  def settings
    {}
  end

  def permitted_params
    params[:static_page].permit!
  end
end
