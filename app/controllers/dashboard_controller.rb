class DashboardController < ApplicationController
  before_action :require_authorization
  def index
    @user = current_user
    @upcoming_events = @user.visible_events.upcoming.limit(5)
    @total_events = @user.visible_events.count
    @total_recipients = @user.recipients.count
    @total_budget = @user.visible_events.sum(:budget)
    @total_spent = @user.visible_events.sum { |e| e.total_spent }

    # Calculates percentage of the gifts purchased
    total_gifts = GiftIdea.joins(event_recipient: :event).where(events: { user_id: @user.id }).count
    purchased_gifts = GiftIdea.joins(event_recipient: :event).where(events: { user_id: @user.id }, status: ['purchased', 'delivered']).count
    @gifts_purchased_percentage = total_gifts > 0 ? ((purchased_gifts.to_f / total_gifts) * 100).round : 0
  end

end
