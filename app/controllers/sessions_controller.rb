class SessionsController < ApplicationController
  before_action :redirect_if_authorized, only: [:new, :create]

  def new
    
  end

  def create
    username = params[:username].to_s
    user = User.find_by("LOWER(username) = ?", username.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid username/password."
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out."
  end
end