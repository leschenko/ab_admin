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

  def custom_settings
    {search: false}
  end
end
