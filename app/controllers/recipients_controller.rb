class RecipientsController < ApplicationController
  before_action :require_authorization
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]

  def index
    @recipients = current_user.recipients
      .includes(:events)
      .order(:name)
    if params[:query].present?
      q = "%#{params[:query].downcase}%"
      @recipients = @recipients.where("LOWER(recipients.name) LIKE ?", q)
    end
  end

  def search
    query = params[:query].to_s.strip
    if query.present?
      pattern = "%#{query.downcase}%"
      @recipients = @scope.where("LOWER(recipients.name) LIKE ?", pattern)
    else
      @recipients = @scope.order(:name)
    end
  end
  def show; end

  def new 
    @recipient = current_user.recipients.new
    @events = current_user.events.order(:name)
  end

  def create
    attrs = normalized_params
    @recipient = current_user.recipients.new(attrs)
    if @recipient.save
      redirect_to recipients_path(current_user), notice: "Recipient created."
    else
      @events = current_user.events.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = current_user.events.order(:name)
  end
  
  def update
    attrs = normalized_params
    if @recipient.update(attrs)
      redirect_to recipients_path
    else
      @events = current_user.events.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipient.destroy
    redirect_to recipients_path
  end

  private
  RELATIONSHIP_DEFAULTS = ["Parent", "Sibling", "Partner/Spouse", "Child", "Relative", "Friend", "Coworker", "Other"]
  
  def recipient_params
    params.require(:recipient).permit(:name, :birthday, :relationship, :relationship_other, :likes, :dislikes, :visible, event_ids: [])
  end
  def set_recipient
    @recipient = current_user.recipients.find(params[:id])
  end
  
  def normalized_params
    attrs = recipient_params.to_h
    attrs.each do |key, val|
        attrs[key] = nil if val.blank?
    end
    attrs
  end

  def set_scope
    @scope = current_user
      .recipients
      .includes(:events, :gift_ideas)
  end
end