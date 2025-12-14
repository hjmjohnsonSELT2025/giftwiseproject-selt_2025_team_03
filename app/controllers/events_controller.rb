class EventsController < ApplicationController
  before_action :require_authorization
  before_action :set_owned_event, only: %i[show edit update destroy]
  before_action :set_visible_event, only: %i[leave]
  before_action :require_event_edit_access, only: %i[edit update destroy]

  def index
    @event_invitations = current_user.received_event_invitations.includes(:event, :inviter)
    @events = current_user.visible_events.order(:date)
  end

  def search
    query = params[:query].to_s.strip
    @events = current_user.visible_events.where("name ILIKE ?", "%#{query}%").order(:date)
    render json: @events.as_json(only: %i[id name date budget location theme])
  end

  def show
    @messages = @event.event_messages.includes(:user).order(created_at: :asc)
    @message = EventMessage.new
  end

  def new
    @event = current_user.owned_events.new
  end

  def create
    @event = current_user.owned_events.new(event_params)
    if @event.save
      update_event_recipients(@event)
      redirect_to events_path, notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      update_event_recipients(@event)
      redirect_to events_path, notice: "Event updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event deleted."
  end

  def leave
    if @event.creator == current_user
      redirect_to event_discussion_path(@event), alert: "You cannot leave an event you created.", status: :see_other
      return
    end

    Attendee.where(event_id: @event.id, user_id: current_user.id).destroy_all
    redirect_to event_discussions_path, notice: "You left the event."
  end

  private

  def event_params
    params.require(:event).permit(:name, :date, :budget, :location, :theme)
  end

  def update_event_recipients(event)
    recipient_ids = Array(params.dig(:event, :recipient_ids)).reject(&:blank?)
    event.event_recipients.where.not(recipient_id: recipient_ids).destroy_all
    recipient_ids.each do |rid|
      event.event_recipients.find_or_create_by(recipient_id: rid)
    end
  end

  def set_owned_event
    @event = current_user.owned_events.find_by(id: params[:id])
    redirect_to(events_path, alert: "Not authorized to view this event.", status: :see_other) unless @event
  end

  def set_visible_event
    @event = current_user.visible_events.find_by(id: params[:id])
    redirect_to(events_path, alert: "Not authorized to access this event.", status: :see_other) unless @event
  end

  def require_event_edit_access
    redirect_to(events_path, alert: "Not authorized to edit this event.", status: :see_other) unless @event&.editable_by?(current_user)
  end
end
