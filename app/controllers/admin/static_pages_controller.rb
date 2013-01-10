class Admin::StaticPagesController < Admin::BaseController
  load_and_authorize_resource

  belongs_to :structure, :singleton => true

  def settings
    {}
  end

  def parent_class
    Structure
  end
end
