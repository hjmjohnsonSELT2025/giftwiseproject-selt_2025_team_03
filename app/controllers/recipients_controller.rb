class RecipientsController < ApplicationController
  before_action :require_authorization
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]
  def index
    @recipients = @current_user.recipients.order(:name)    
  end

  def search
      query = params[:query].to_s.strip
      recipients = if query.present?
        pattern = "%#{query.downcase}%"
        @scope.where("LOWER(recipients.name) LIKE ?", pattern)
      else
        @scope.order(:name)
      end
      render json: {
        recipients: recipients.map { |r| 
        {
          id: r.id,
          name: r.name,
          relationship: r.relationship,
          events: r.events.map(&:name),
          likes: r.likes,
          dislikes: r.dislikes
        }
      }
      }, status: :ok
  end
  def show; end

  def new 
    @recipient = current_user.recipients.new
    @events = current_user.events.order(:name)
  end

  def create 
    @recipient = current_user.recipients.new(recipient_params)
    if @recipient.save
      redirect_to recipients_path(@current_user), notice: "Recipient created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = current_user.events.order(:name)
  end
  def update
    if @recipient.update(recipient_params)
      redirect_to recipients_path, notice: "Recipient updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipient.destroy
    redirect_to recipients_path, notice: "Recipient deleted."
  end

  private
  def set_recipient
    @recipient = @current_user.recipients.find(params[:id])
  end

  def recipient_params
    params.require(:recipient).permit(:name, :birthday, :relationship, :relationship_other, :likes, :dislikes, event_ids: [])
  end

  def set_scope
    @scope = current_user
      .recipients
      .includes(:events, :gift_ideas)
  end
end