Rails.application.routes.draw do

  namespace :admin do
    root to: 'dashboards#index'
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
    end

    resource :settings, only: [:edit, :update] do
      post :cache_clear, on: :collection
    end

    resource :locators do
      post :prepare, :reload, on: :collection
    end

    resources :admin_comments

    post 'translate' => AbAdmin::I18nTools::TranslateApp

    controller 'manager' do
      scope '(/:parent_resource/:parent_resource_id)/:model_name' do
        get '/new', to: :new, as: 'new'
        post '/batch', to: :batch, as: 'batch'
        post '/rebuild', to: :rebuild, as: 'rebuild'
        match '/custom_action', to: :custom_action, as: 'collection_action'

        scope ':id' do
          get '/edit', to: :edit, as: 'edit'
          get '/history', to: :history, as: 'history'
          match '/custom_action', to: :custom_action, as: 'member_action'
          get '/', to: :show, as: 'show'
          put '/', to: :update, as: 'update'
          delete '/', to: :destroy, as: 'destroy'
        end

        get '/', to: :index, as: 'index'
        post '/', to: :create, as: 'create'
      end
    end

  end

end
