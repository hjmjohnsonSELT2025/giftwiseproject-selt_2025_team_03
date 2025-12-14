class RecipientsController < ApplicationController
  before_action :require_authorization
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]

  def index
    @recipients = @scope.order(:name)

    if params[:query].present?
      q = "%#{params[:query].downcase}%"
      @recipients = @recipients.where("LOWER(recipients.name) LIKE ?", q)
    end
  end

  def search
    query = params[:query].to_s.strip

    gift_ideas = if query.present?
                   pattern = "%#{query.downcase}%"
                   @scope.where("LOWER(recipients.name) LIKE ?", pattern).order(:name)
                 else
                   @scope.order(:name)
                 end

    respond_to do |format|
      format.json do
        render json: {
          recipients: gift_ideas.map { |r|
            {
              id: r.id,
              name: r.name,
              relationship: r.relationship,
              likes: r.likes,
              dislikes: r.dislikes
            }
          }
        }
      end
      format.html { redirect_to recipients_path(query: params[:query]) }
    end
  end

  def show
  end

  def new
    @recipient = current_user.recipients.new
    @events = current_user.events.order(:name)

    if params[:user_id].present?
      begin
        source_user = User.find(params[:user_id])
        @recipient.name = [source_user.first_name, source_user.last_name].compact.join(" ")
        @recipient.likes = source_user.likes
        @recipient.dislikes = source_user.dislikes
        @recipient.relationship = "Other"
      rescue ActiveRecord::RecordNotFound
        # Do nothing, let the recipient object remain pristine
      end
    end
  end

  def create
    attrs = normalized_params
    attrs[:relationship_other] = nil unless attrs[:relationship] == 'Other'

    @recipient = current_user.recipients.new(attrs)

    if @recipient.save
      redirect_to recipients_path, notice: "Recipient created."
    else
      @events = current_user.events.order(:name)

      if @recipient.errors[:name].any?
        flash.now[:alert] = "'#{@recipient.name}' #{@recipient.errors[:name].join(', ')}"
      else
        flash.now[:alert] = @recipient.errors.full_messages.to_sentence
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = current_user.events.order(:name)
  end

  def update
    attrs = normalized_params
    attrs[:relationship_other] = nil unless attrs[:relationship] == 'Other'

    if @recipient.update(attrs)
      redirect_to recipients_path, notice: "Recipient updated."
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

  def recipient_params
    params.require(:recipient).permit(:name, :birthday, :relationship, :relationship_other, :likes, :dislikes, :visible, event_ids: [])
  end

  def set_recipient
    @recipient = current_user.recipients.find(params[:id])
  end

  def normalized_params
    attrs = recipient_params.to_h

    # Normalize blanks to nil, except for booleans like :visible
    attrs.each do |key, val|
      attrs[key] = nil if val.blank? && key.to_s != 'visible'
    end

    attrs
  end

  def set_scope
    @scope = current_user
               .recipients
               .includes(:events, :gift_ideas)
  end
end