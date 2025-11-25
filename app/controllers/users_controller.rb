class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    render :dashboard
  end
  def login

  end
  def authorize
    username = params[:username].to_s.strip
    user = User.where('lower(username) = ?', username.downcase).first
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      Rails.logger.debug "user successfully logged in"
      redirect_to user_path(user), notice: "Now logged in"
    else
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
      #session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome, #{@user.username}"
    else
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
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)
  end
end
