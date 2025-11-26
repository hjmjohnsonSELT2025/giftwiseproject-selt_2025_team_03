class UsersController < ApplicationController
  before_action :require_authorization, :only => [:show, :logout]
  before_action :redirect_if_authorized, :only => [:login, :new, :create]

  def show
    @user = User.find(params[:id])
    redirect_to dashboard_path
  end
  def login

  end
  def authorize 
    username = params[:username].to_s.strip
    user = User.where('lower(username) = ?', username.downcase).first
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      Rails.logger.debug "User #{username} successfully logged in"
      redirect_to dashboard_path, notice: "Now logged in"
    else
      Rails.logger.debug "Invalid credentials received."
      redirect_to login_path, alert: "Invalid username/password."
    end
  end
  def new
    #@user = User.new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Welcome, #{@user.username}!"
    else
      Rails.logger.warn "Failed to create an account: #{user.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end

  # (logout)
  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out."
  end

  def check_email
    email = params[:email].to_s.strip.downcase
    if User.exists?(email: email)
      render json: {
        available: false
      }, :status => :conflict
    else
      render json: {available: true}, :status => :ok
    end
  end



  private
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name, :birthday)
  end
end