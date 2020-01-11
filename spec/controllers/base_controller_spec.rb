require 'spec_helper'

RSpec.describe Admin::BaseController, type: :controller do
  describe '#per_page' do
    before do
      @orig_routes, @routes = @routes, ActionDispatch::Routing::RouteSet.new
      @routes.draw { get '/admin/base' => 'admin/base#index' }
      controller.send(:build_settings)
    end

    after do
      @routes, @orig_routes = @orig_routes, nil
    end

    it 'return default per_page' do
      get :index
      expect(controller.send(:per_page)).to eq 50
    end

    it 'return user request per_page' do
      get :index, params: {per_page: 11}
      expect(controller.send(:per_page)).to eq 11
    end

    it 'allow value only less than max' do
      get :index, params: {per_page: 20_000}
      expect(controller.send(:per_page)).to eq 10_000
    end
  end
end