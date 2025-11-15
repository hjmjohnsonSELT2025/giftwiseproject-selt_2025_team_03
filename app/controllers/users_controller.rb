class UsersController < ApplicationController
  def login

  end
  def authorize
    render js: q{console.log("authorizing request"); }
    input = params[:login]
    user = User.find_by(email: input) || User.find_by(username: input)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Now logged in."
    else
      flash[:alert] = "Invalid username/email or password."
      render :login, status: :unauthorized
    end
  end
  def new
    #@user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      # session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome, #{@user.username}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # (logout)
  def destroy
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

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def show

  end
end
