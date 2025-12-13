class DashboardController < ApplicationController
  before_action :require_authorization

  def index
    @user = current_user
    @upcoming_events = @user.events.upcoming.limit(5)
    @total_events = @user.events.count
    @total_recipients = @user.recipients.count
    @total_budget = @user.events.sum(:budget)
    @total_spent = @user.events.sum { |e| e.total_spent }

    # Get period from params, default to 7 days
    @period = params[:period]&.to_i || 7

    # Calculate spending data for the chart
    @spending_data = calculate_spending_by_day(@period)

    # Calculates percentage of the gifts purchased
    total_gifts = GiftIdea.joins(event_recipient: :event).where(events: { user_id: @user.id }).count
    purchased_gifts = GiftIdea.joins(event_recipient: :event).where(events: { user_id: @user.id }, status: ['purchased', 'delivered']).count
    @gifts_purchased_percentage = total_gifts > 0 ? ((purchased_gifts.to_f / total_gifts) * 100).round : 0

    # Respond with JSON if requested, otherwise render HTML
    respond_to do |format|
      format.html
      format.json { render json: @spending_data }
    end
  end

  private

  def calculate_spending_by_day(days)
    start_date = days.days.ago.to_date
    end_date = Date.today

    # Get all purchased gifts within the date range
    gifts = GiftIdea.joins(event_recipient: :event)
                    .where(events: { user_id: current_user.id })
                    .where(status: ['purchased', 'delivered'])
                    .where('gift_ideas.updated_at >= ?', start_date)

    # Group by date and sum prices
    spending_by_date = {}
    (start_date..end_date).each do |date|
      spending_by_date[date.strftime('%m/%d')] = 0
    end

    gifts.each do |gift|
      date_key = gift.updated_at.to_date.strftime('%m/%d')
      spending_by_date[date_key] += gift.price.to_f if gift.price && spending_by_date.key?(date_key)
    end

    # Calculate cumulative spending
    cumulative = 0
    spending_by_date.transform_values do |amount|
      cumulative += amount
    end
  end

end