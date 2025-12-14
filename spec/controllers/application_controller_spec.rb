require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action :require_authorization, only: [:protected_action]
    before_action :redirect_if_authorized, only: [:login_action]

    def protected_action
      render plain: "ok"
    end

    def login_action
      render plain: "ok"
    end
  end

  before do
    routes.draw do
      get "protected_action" => "anonymous#protected_action"
      get "login_action" => "anonymous#login_action"
      get "/login" => "anonymous#login_action", as: :login
      get "/dashboard" => "anonymous#protected_action", as: :dashboard
    end
  end

  let(:user) do
    User.create!(
      email: "test@example.com",
      password: "password",
      username: "testuser",
      first_name: "Test",
      last_name: "User"
    )
  end

  describe "#current_user" do
    it "returns user when session[:user_id] is set" do
      session[:user_id] = user.id
      expect(controller.current_user).to eq(user)
    end

    it "returns nil when no user is logged in" do
      expect(controller.current_user).to be_nil
    end
  end

  describe "#logged_in?" do
    it "returns true when logged in" do
      session[:user_id] = user.id
      expect(controller.logged_in?).to be true
    end

    it "returns false when not logged in" do
      expect(controller.logged_in?).to be false
    end
  end

  describe "#require_authorization" do
    it "allows access when logged in" do
      session[:user_id] = user.id
      get :protected_action
      expect(response).to have_http_status(:ok)
    end

    it "redirects to login_path when not logged in" do
      get :protected_action
      expect(response).to redirect_to(login_path)
    end
  end

  describe "#redirect_if_authorized" do
    it "redirects to dashboard_path when logged in" do
      session[:user_id] = user.id
      get :login_action
      expect(response).to redirect_to(dashboard_path)
    end

    it "allows access when not logged in" do
      get :login_action
      expect(response).to have_http_status(:ok)
    end
  end
end
