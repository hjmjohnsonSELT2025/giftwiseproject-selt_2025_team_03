Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  ##########################################################
  root 'sessions#new'                                # ROOT
  #########################################################

  #---------------------  SESSION MANAGEMENT
  resource :session, only: [:new, :create, :destroy]
  get "/", :to => "sessions#new"
  get "/login", :to => "sessions#new", as: :login
  post '/login', :to => 'sessions#create'
  delete '/logout', :to => 'sessions#destroy', as: :logout

  #---------------------  DASHBOARD
  get 'dashboard', to: 'dashboard#index', as: 'dashboard', defaults: { format: :html }

  #---------------------  EVENTS
  resources :events do
    collection { get :search }
  end
  #---------------------  EVENT DISCUSSIONS
  resources :event_discussions, only: %i[index show] do
    resources :event_messages, only: [:create]
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
  resources :gift_ideas do
    collection { get :search }
  end
  match "*path", to: "application#render_not_found", via: :all
end