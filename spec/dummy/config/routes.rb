Rails.application.routes.draw do

  root to: 'welcome#index'

  resources :products

  devise_for :users, ::AbAdmin::Devise.config

  #namespace :admin do
  #  root to: 'dashboards#index'
  #end

  mount Ckeditor::Engine => '/ckeditor'

end
