Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: [:new, :create, :destroy]
  get "login", to: "sessions#new", as: :login
  delete "logout", to: "sessions#destroy", as: :logout
  root 'sessions#new'


  get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  resources :events do
    collection do
      get :search
    end
  end
  get "/preview_profile", to: "preview#profile"

  # logging in/out
  resources :users, only: [:new, :create, :show] do
    collection do
      post :check_email
      post :check_username
    end
  end
  resource :profile, only: [:edit, :update], controller: "users"

  post 'users/check_email', :to => "users#check_email"
  post 'users/check_username', :to => "users#check_username"
  # recipients
  resources :recipients do
    collection do
      get :search
    end
  end
  # gift_ideas
  resources :gift_ideas, only: [:new, :create, :show]
  get "/list_gifts", :to => "gift_ideas#list", as: :list_gifts
  get "/add_gifts", :to => "gift_ideas#add", as: :add_gifts
  post "/add_gifts", :to => "gift_ideas#list"
  #get "/model_gifts", :to => "gift_ideas#model", as: :model_gifts
  #get "/obtain_gifts", :to => "gift_ideas#obtain", as: :obtain_gifts
  #get "/edit_gift", :to => "gift_idea#edit"
  #get "/search_gifts", :to => "gift_ideas#search", as: :search_gifts

  # chats
  resources :chats, only: [:new, :create, :show]
  get "/query_chat", :to => "chats#query", as: :query_chat
  post "/query_chat", :to => "chats#query"
end