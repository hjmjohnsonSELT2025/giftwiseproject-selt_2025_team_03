class DashboardController < ApplicationController
  before_action :require_login
  def index
    @user = current_user
    @upcoming_events = @user.events.upcoming.limit(5)
    @total_events = @user.events.count
    @total_recipients = @user.recipients.count
    @total_budget = @user.events.sum(:budget)
    @total_spent = @user.events.sum { |e| e.total_spent }
  end
end
