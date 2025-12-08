class UsersController < ApplicationController
  before_action :require_authorization, except: [:new, :create]
  before_action :set_user, only: [:show]
  before_action :ensure_profile_visible!, only: :show
  def show
    
    redirect_to dashboard_path
  end
  def edit
    @user = current_user
  end
  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to dashboard_path, notice: "Profile updated."
    else
      Rails.logger.debug "Invalid credentials received."
      render :edit, status: :unprocessable_entity, alert: "Invalid username/password."
    end
  end
  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Welcome, #{@user.username}!"
    else
      Rails.logger.warn "Failed to create an account: #{@user.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
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
  def set_user
    @user = User.find(params[:id])
  end
  def ensure_profile_visible!
      return if @user == current_user
      #return if @user.public_profile?
      render status: :forbidden
  end
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name, :birthday, public_profile: false)
  end
end