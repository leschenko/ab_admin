class Admin::StaticPagesController < Admin::BaseController
  load_and_authorize_resource

  defaults singleton: true, class_name: 'Structure'

  belongs_to :structure, finder: :friendly_find

  private

  def settings
    {}
  end

  def permitted_params
    attrs = [:structure_id, :title, :content, :kind, :is_visible,
             *StaticPage.all_translated_attribute_names, *AbAdmin.default_permitted_params]
    params[:static_page].try!(:permit, *attrs)
  end
end
