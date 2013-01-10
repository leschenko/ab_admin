Rails.application.routes.draw do
  #root :to => 'welcome#index'

  #devise_for :users

  namespace :admin do
    root :to => 'dashboards#index'
    resources :dashboards, :only => :index

    resources :structures do
      post :rebuild, :on => :collection
      resource :static_page
    end

    resources(:users) do
      post :batch, :on => :collection
      post :activate, :suspend, :send_welcome, :on => :member
    end

    resources :assets, :only => [:create, :destroy] do
      post :rotate, :main, :crop, :on => :member
      post :sort, :on => :collection
    end
  end


end
