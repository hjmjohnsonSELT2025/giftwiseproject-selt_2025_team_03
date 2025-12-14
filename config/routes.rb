Rails.application.routes.draw do
  root "sessions#new"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :sessions, only: [:new, :create] do
    delete :destroy, on: :collection
  end

  resources :users, except: [:index] do
    get :find, on: :collection
    get :search, on: :collection
    get :new_event_invitation, on: :member
    post :create_event_invitation, on: :member
  end

  resources :recipients do
    collection do
      get :search
      get :find
      get :find_recipients
    end
  end

  resources :events do
    member { delete :leave }
    collection do
      get :search
    end
    resources :event_invitations, only: [:create]
  end

  resources :event_invitations, only: [] do
    member do
      post :accept
      delete :decline
    end
  end

  resources :dashboard, only: [:index]

  resources :event_discussions, only: [:index, :show] do
    resources :event_messages, only: [:create]
  end
end
