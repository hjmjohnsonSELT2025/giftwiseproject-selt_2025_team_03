Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "users#login"

  # logging in/out
  get "/login", :to => "users#login"
  #post "/users/check_email", :to => "users#check_email"
  #post "/login", :to => "users#authorize"
  #post "/logout", :to => "users#destroy", :as => :logout

  # signing up

  resources :users do
    collection do
      post 'authorize'
      post 'logout'
      post 'check_email'
      post 'create'
    end
  end
end
