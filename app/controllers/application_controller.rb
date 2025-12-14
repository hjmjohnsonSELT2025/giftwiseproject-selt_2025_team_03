class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from ActionController::MethodNotAllowed, with: :render_not_found
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  def current_user 
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(:id => session[:user_id])
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
  private
  def render_not_found
        respond_to {|format| 
        format.html { 
          render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
        format.any { head :not_found }}
  end
end
