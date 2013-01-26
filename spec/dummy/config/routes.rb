Rails.application.routes.draw do
  root :to => redirect('/')

  devise_for :users, AbAdmin::Devise.config

end
