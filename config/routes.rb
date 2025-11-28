Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "users#login"

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  resources :events

  get "/preview_profile", to: "preview#profile"

  # logging in/out
  get "/", :to => "users#login"
  get "/login", :to => "users#login", as: :login
  post '/login', :to => 'users#authorize'
  delete '/logout', :to => 'users#logout', as: :logout
  resources :users, only: [:new, :create, :show]
  post 'users/check_email', :to => "users#check_email"
  post 'users/check_username', :to => "users#check_username"
  # recipients
  resources :gift_ideas, only: [:new, :create, :show]
  resources :recipients do
    collection do
      get :search
      get :new
    end
  end
  # gift_ideas
  get "/list_gifts", :to => "gift_ideas#list", as: :list_gifts
  get "/add_gifts", :to => "gift_ideas#add", as: :add_gifts
  post "/add_gifts", :to => "gift_ideas#list"
end
