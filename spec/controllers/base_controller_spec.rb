require 'spec_helper'

describe Admin::BaseController, type: :controller do
  describe '#per_page' do
    before do
      AbAdmin.default_per_page = 30
      AbAdmin.view_default_per_page[:tree] = 500
      AbAdmin.max_per_page = 1000
    end

    before do
      @orig_routes, @routes = @routes, ActionDispatch::Routing::RouteSet.new
      @routes.draw { get '/admin/base' => 'admin/base#index' }
    end

    after do
      @routes, @orig_routes = @orig_routes, nil
    end

    it 'return default per_page' do
      get :index
      expect(controller.send(:per_page)).to eq 30
    end

    it 'return user request per_page' do
      get :index, per_page: 11
      expect(controller.send(:per_page)).to eq 11
    end

    it 'allow value only less than max' do
      get :index, per_page: 9999
      expect(controller.send(:per_page)).to eq 1000
    end

    it 'return view default per_page' do
      allow_any_instance_of(Admin::BaseController).to receive(:current_index_view).and_return('tree')
      get :index
      expect(controller.send(:per_page)).to eq 500
    end

    it 'return view default per_page' do
      allow_any_instance_of(Admin::BaseController).to receive(:settings).and_return({max_per_page: 40})
      get :index, per_page: 9999
      expect(controller.send(:per_page)).to eq 40
    end
  end
end