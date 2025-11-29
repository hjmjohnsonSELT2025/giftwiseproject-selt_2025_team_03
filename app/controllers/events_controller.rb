class EventsController < ApplicationController
  before_action :require_authorization

  def index
    @events = current_user.events.order(:date)
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

  private

  def event_params
    params.require(:event).permit(:name, :date, :location, :theme, :budget)
  end
end