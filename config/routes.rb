Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  ##########################################################
  root 'sessions#new'                                # ROOT
  #########################################################
  
  #---------------------  SESSION MANAGEMENT
  resource :session, only: [:new, :create, :destroy]
  get "login", to: "sessions#new", as: :login
  delete "logout", to: "sessions#destroy", as: :logout

  #---------------------  DASHBOARD
  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  #---------------------  EVENTS
  resources :events do
    collection do
      get :search
    end
  end

  #---------------------  EVENT INVITATIONS
  resources :event_invitations, only: [:index, :update]

  #---------------------  PROFILE
  get "/preview_profile", to: "preview#profile"

  #---------------------  USERS
  resource :profile, only: [:edit, :update], controller: "users"
  resources :users, only: [:new, :create, :show] do
    collection do
      post :check_email
      post :check_username
      get :find
    end
    member do
      get :new_event_invitation
      post :create_event_invitation
    end
  end
  post 'users/check_email', :to => "users#check_email"
  post 'users/check_username', :to => "users#check_username"

  #---------------------  RECIPIENTS
  resources :recipients do
    collection do
      get :search
    end
  end
  #---------------------  GIFT IDEAS
  resources :gift_ideas, only: [:new, :create, :show]
  get "/list_gifts", :to => "gift_ideas#list", as: :list_gifts
  get "/add_gifts", :to => "gift_ideas#add", as: :add_gifts
  post "/add_gifts", :to => "gift_ideas#list"

  #get "/edit_gift", :to => "gift_idea#edit"
  #get "/search_gifts", :to => "gift_ideas#search", as: :search_gifts
end