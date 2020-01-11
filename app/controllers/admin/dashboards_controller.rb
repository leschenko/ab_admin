class Admin::DashboardsController < Admin::BaseController

  def index
  end

  private

  def collection
    []
  end

  def action_items
    []
  end

  def build_settings
    @settings = {}
  end
end
