class EventDiscussionsController < ApplicationController
  before_action :require_authorization
  before_action :set_event, only: [:show]

  def index
    @events = current_user.visible_events
      .left_outer_joins(:event_messages)
      .select("events.*, MAX(event_messages.created_at) AS last_message_at")
      .group("events.id")
      .order(Arel.sql("last_message_at DESC NULLS LAST, events.date ASC"))
      .includes(last_event_message: :user)
  end

  def show
    @messages= @event.event_messages.includes(:user).order(:created_at)
    @message = @event.event_messages.new
  end
  private
  def set_event
    @event = current_user.visible_events.find_by(id: params[:id])
    redirect_to(event_discussions_path, alert: "Discussion not found.") and return unless @event
  end
end