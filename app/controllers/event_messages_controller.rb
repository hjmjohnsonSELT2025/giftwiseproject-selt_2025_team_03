class EventMessagesController < ApplicationController
  before_action :require_authorization
  before_action :set_event
  
  def create
    @message = @event.event_messages.new(message_params.merge(user: current_user))  
    if @message.save
      redirect_to event_discussion_path(@event), notice: "Message posted."
    else
      @messages = @event.event_messages.includes(:user).order(:created_at)
      render "event_discussions/show", status: :unprocessable_entity
    end
  end
  private
  def set_event
    event_id = params[:event_id] || params[:event_discussion_id]
    @event = current_user.visible_events.find_by(id: event_id)
    redirect_to(event_discussions_path, alert: "Discussion not found.") and return unless @event

  end
  def message_params
    params.require(:event_message).permit(:body)
  end
end