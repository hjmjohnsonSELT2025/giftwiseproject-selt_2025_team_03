class EventsController < ApplicationController
  before_action :require_authorization
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = current_user.events.order(:date)
  end

  def search
    query = params[:query].to_s.strip.downcase

    events = if query.present?
               current_user.events.where(
                 "LOWER(name) LIKE ? OR LOWER(location) LIKE ? OR LOWER(theme) LIKE ?",
                 "%#{query}%", "%#{query}%", "%#{query}%"
               ).order(:date)
             else
               current_user.events.order(:date)
             end

    render json: {
      events: events.map { |e|
        {
          id: e.id,
          name: e.name,
          date: e.date.strftime("%B %d, %Y"),
          location: e.location,
          theme: e.theme,
          budget: e.budget&.to_f || 0,
          recipients_count: e.recipients.count,
          days_until: e.days_until
        }
      }
    }
  end

  def show

  end

  def new
    @event = current_user.events.new
    @recipients = current_user.recipients.order(:name)
  end

  def create
    @event = current_user.events.new(event_params)

    if @event.save
      if params[:recipient_ids].present?
        params[:recipient_ids].each do |recipient_id|
          @event.event_recipients.create(recipient_id: recipient_id)
        end
      end

      redirect_to events_path, notice: "Event created successfully!"
    else
      @recipients = current_user.recipients.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @recipients = current_user.recipients.order(:name)
  end

  def update
    if @event.update(event_params)
      # Update recipients
      if params[:recipient_ids].present?
        @event.event_recipients.destroy_all
        params[:recipient_ids].each do |recipient_id|
          @event.event_recipients.create(recipient_id: recipient_id)
        end
      end

      redirect_to events_path, notice: "Event updated successfully!"
    else
      @recipients = current_user.recipients.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_path, notice: "Event deleted successfully!" }
      format.json { render json: { success: true }, status: :ok }
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :date, :location, :theme, :budget)
  end
end