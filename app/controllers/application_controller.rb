class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  def current_user 
    @current_user ||= User.find_by(:id => session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_authorization
    return if logged_in?
    redirect_to login_path
  end

  def redirect_if_authorized
    redirect_to dashboard_path if logged_in?
  end
end
