Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  root :to => 'welcome#index'

  devise_for :users, ::AbAdmin::Devise.config

end
