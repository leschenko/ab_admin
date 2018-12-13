Rails.application.routes.draw do
  namespace :admin do
    root to: 'dashboards#index', as: :root
    get 'dashboards', as: 'dashboards'

    resources :structures do
      post :batch, :rebuild, on: :collection
      resource :static_page
    end

    resources :users do
      post :batch, on: :collection
      post :activate, :suspend, on: :member
    end

    resources :assets, only: [:create, :destroy] do
      post :rotate, :main, :crop, on: :member
      post :sort, on: :collection
      get :batch_edit, on: :collection
      post :batch_update, on: :collection
    end

    resource :settings, only: [:edit, :update] do
      post :cache_clear, on: :collection
    end

    resource :locators do
      post :prepare, :reload, :import, on: :collection
      get :export, on: :collection
    end

    resources :admin_comments

    post 'translate' => AbAdmin::I18nTools::TranslateApp

    scope '(/:parent_resource/:parent_resource_id)/:model_name', controller: 'manager', constraints: {format: /(html|js|json|xml|csv|xls|xlsx)/} do
      get '/new', action: :new, as: 'new'
      post '/batch', action: :batch, as: 'batch'
      post '/rebuild', action: :rebuild, as: 'rebuild'
      match '/custom_action', action: :custom_action, as: 'collection_action', via: :all

      scope ':id' do
        get '/edit', action: :edit, as: 'edit'
        get '/history', action: :history, as: 'history'
        match '/custom_action', action: :custom_action, as: 'member_action', via: :all
        get '/', action: :show, as: 'show'
        patch '/', action: :update, as: 'update'
        delete '/', action: :destroy, as: 'destroy'
      end

      get '/', action: :index, as: 'index'
      post '/', action: :create, as: 'create'
    end
  end
end
