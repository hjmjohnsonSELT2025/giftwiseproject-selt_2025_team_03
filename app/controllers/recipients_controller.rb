class RecipientsController < ApplicationController
  before_action :require_authorization
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]
  def index
    @recipients = current_user.recipients
      .includes(:events, :source_user)
      .order(:name)
    # update recipient attributes if source_user's profile was updated.
    if params[:query].present?
      q = "%#{params[:query].downcase}%"
      @recipients = @recipients.where("LOWER(recipients.name) LIKE ?", q)
    end
  end

  def search
    query = params[:query].to_s.strip
    if query.present?
      pattern = "%#{query.downcase}%"
      @scope.where("LOWER(recipients.name) LIKE ?", pattern)
    else
      @scope.order(:name)
    end
  end
  def show; end

  def new 
    @recipient = current_user.recipients.new
    @events = current_user.events.order(:name)
    if params[:user_id].present?
        source = User.where(public_profile: true).find(params[:user_id])
        if source.nil?
          redirect_to recipients_path, alert: "This user doesn't exist or their profile is private."
          return
        end
        @recipient.source_user = source
        @recipient.relationship = "Other"
    end
  end

  def add
    @recipient = current_user.recipients.new
    if params[:user_id].present?
        source_user = User.where(public_profile: true).find(params[:user_id])
        @recipient.name = [source_user.first_name, source_user.last_name].compact.join(" ")
        @recipient.likes = source_user.likes.to_s
        @recipient.dislikes = source_user.dislikes.to_s
        @recipient.relationship = "Other"
        @recipient.birthday = source_user.birthday
    end
  end

  def create
    attrs = normalized_params
    @recipient = current_user.recipients.new(attrs)
    if params[:user_id].present?
            source = User.find_by(id: params[:user_id], public_profile: true)
            @recipient.source_user = source if source
            @recipient.relationship ||= "Other" if source
    end
    if @recipient.save
      redirect_to recipients_path, notice: "Recipient created."
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
    respond_to do |f|
            f.html { redirect_to recipients_path, notice: "Recipient deleted."}
            f.json { render json: { success: true}, status: :ok }
    end
  end

  private
  RELATIONSHIP_DEFAULTS = ["Parent", "Sibling", "Partner/Spouse", "Child", "Relative", "Friend", "Coworker", "Other"]
  
  def recipient_params
    params.require(:recipient).permit(:name, :birthday, :relationship, :relationship_other, :likes, :dislikes, event_ids: [])
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