Rails.application.routes.draw do

  namespace :admin do
    root :to => 'dashboards#index'
    resources :dashboards, :only => :index

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

    post 'translate' => AbAdmin::I18nTools::TranslateApp

    controller 'manager' do
      scope ':model_name' do
        get '/', :to => :index, :as => 'index'
        post '/', :to => :create, :as => 'create'
        get '/new', :to => :new, :as => 'new'
        post '/batch', :to => :batch, :as => 'batch'
        post '/rebuild', :to => :rebuild, :as => 'rebuild'

        scope ':id' do
          get '/', :to => :show, :as => 'show'
          get '/edit', :to => :edit, :as => 'edit'
          put '/', :to => :update, :as => 'update'
          delete '/', :to => :destroy, :as => 'destroy'
        end
      end
    end

  end

end
