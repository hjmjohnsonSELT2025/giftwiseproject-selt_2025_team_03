class RecipientsController < ApplicationController
  before_action :require_authorization
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]
  def index
    @recipients = @current_user.recipients
      .includes(:events)
      .order(:name)
    if params[:query].present?
      q = "%#{params[:query].downcase}%"
      @recipients = @recipients.where("LOWER(recipients.name) LIKE ?", q)
    end
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
    attrs = recipient_params.to_h
    attrs[:birthday] = nil if attrs[:birthday].blank?
    
    attrs.delete(:relationship_other)
    @recipient = current_user.recipients.new(attrs)
    if @recipient.save
      redirect_to recipients_path(@current_user), notice: "Recipient created."
    else
      @events = current_user.events.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = current_user.events.order(:name)
    unless RecipientsController::REL_OPTIONS.include?(@recipient.relationship)
        @recipient.relationship_other = @recipient.relationship
        @recipient.relationship = "Other"
    end
  end
  
  def update
    attrs = normalized_params
    if @recipient.update(attrs)
      redirect_to recipients_path, notice: "Recipient updated."
    else
      @events = current_user.events.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipient.destroy
    redirect_to recipients_path, notice: "Recipient deleted."
  end

  private
  REL_OPTIONS = ["Parent", "Sibling", "Partner/Spouse", "Child", "Relative", "Friend", "Coworker", "Other"]
  def set_recipient
    @recipient = @current_user.recipients.find(params[:id])
  end

  def recipient_params
    params.require(:recipient).permit(:name, :birthday, :relationship, :likes, :dislikes, event_ids: [])
  end

  def normalized_params
    attrs = recipient_params.to_h
    # bday
    attrs[:birthday] = nil if attrs[:birthday].blank?
    # other--
    if attrs[:relationship] == "Other"
      other = attrs[:relationship_other].to_s.strip
      attrs[:relationship] = other if other.present?
    end
    attrs.delete(:relationship_other)
    attrs
  end

  def set_scope
    @scope = current_user
      .recipients
      .includes(:events, :gift_ideas)
  end
end