Rails.application.routes.draw do
  namespace :admin do
    root to: 'dashboards#index', as: :root
    get 'dashboards', as: 'dashboards'

    resources :structures do
      collection do
        post :batch
        post :rebuild
      end
      resource :static_page
    end

    resources :users do
      collection do
        post :batch
      end
      member do
        post :activate
        post :suspend
      end
    end

    resources :assets, only: [:create, :destroy] do
      member do
        post :rotate
        post :main
        post :crop
      end
      collection do
        post :sort
        get :batch_edit
        post :batch_update
      end
    end

    resource :settings, only: [:edit, :update] do
      collection do
        post :cache_clear
      end
    end

    resource :locators do
      collection do
        post :prepare
        post :reload
        post :import
        get :export
      end
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
