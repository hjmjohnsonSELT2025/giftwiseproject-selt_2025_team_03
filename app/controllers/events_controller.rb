class EventsController < ApplicationController
  before_action :require_authorization

  def index
    @events = current_user.events.order(:date)
  end

  def new
    @event = current_user.events.new
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      redirect_to events_path, notice: "Event created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :date, :location, :theme, :budget)
  end
end