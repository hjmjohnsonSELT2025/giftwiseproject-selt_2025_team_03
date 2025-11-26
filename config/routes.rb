Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "users#login"

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  get "/preview_profile", to: "preview#profile"

  # logging in/out
  get "/login", :to => "users#login", as: :login
  post '/login', :to => 'users#authorize'
  delete '/logout', :to => 'users#logout'
  resources :users, only: [:new, :create, :show]
  post 'users/check_email', :to => "users#check_email"
  post 'users/check_username', :to => "users#check_username"
  # recipients
  resources :recipients
end
