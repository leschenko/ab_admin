Rails.application.routes.draw do

  namespace :admin do
    root :to => 'dashboards#index'
    get 'dashboards', :as => 'dashboards'

    resources :structures do
      post :rebuild, :on => :collection
      resource :static_page
    end

    resources :users do
      post :batch, :on => :collection
      post :activate, :suspend, :send_welcome, :on => :member
    end

    resources :assets, :only => [:create, :destroy] do
      post :rotate, :main, :crop, :on => :member
      post :sort, :on => :collection
    end

    resource :settings, :only => [:edit, :update] do
      post :cache_clear, :on => :collection
    end

    resource :locators do
      post :prepare, :reload, :on => :collection
    end

    resources :admin_comments

    post 'translate' => AbAdmin::I18nTools::TranslateApp

    controller 'manager' do
      scope '(/:parent_resource/:parent_id)/:model_name' do
        get '/new', :to => :new, :as => 'new'
        post '/batch', :to => :batch, :as => 'batch'
        post '/rebuild', :to => :rebuild, :as => 'rebuild'

        scope ':id' do
          get '/edit', :to => :edit, :as => 'edit'
          get '/', :to => :show, :as => 'show'
          put '/', :to => :update, :as => 'update'
          delete '/', :to => :destroy, :as => 'destroy'
        end

        get '/', :to => :index, :as => 'index'
        post '/', :to => :create, :as => 'create'
      end
    end

  end

end
