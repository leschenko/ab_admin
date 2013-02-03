Rails.application.routes.draw do

  root :to => 'welcome#index'

  resources :products

  devise_for :users, ::AbAdmin::Devise.config

  mount Ckeditor::Engine => '/ckeditor'
end
