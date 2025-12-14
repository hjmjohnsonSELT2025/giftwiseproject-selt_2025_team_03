class GiftIdeasController < ApplicationController
  before_action :require_authorization
  before_action :set_gift_idea, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]

  def index
    @gift_ideas = @scope.order(:title)

    if params[:query].present?
      q = "%#{params[:query].downcase}%"
      @gift_ideas = @gift_ideas.where("LOWER(gift_ideas.title) LIKE ?", q)
    end
  end

  def search
    query = params[:query].to_s.strip.downcase

    gift_ideas = @scope

    gift_ideas = if query.present?
                   gift_ideas.where("LOWER(gift_ideas.title) LIKE ?", "%#{query}%")
                 else
                   gift_ideas.order(:title)
                 end

    render json: {
      gift_ideas: gift_ideas.map { |g|
        {
          id: g.id,
          title: g.title,
          price: g.price&.to_f || 0,
          status: g.status,
          url: g.url,
          notes: g.notes,
          event_recipient: {
            event_name: g.event_recipient&.event&.name,
            recipient_name: g.event_recipient&.recipient&.name
          }
        }
      }
    }
  end

  def show
    @event_recipient = @gift_idea.event_recipient
  end

  def new
    @gift_idea = GiftIdea.new
    @event_recipients = current_user.events
                                    .includes(event_recipients: :recipient)
                                    .flat_map(&:event_recipients)
  end

  def create
    @gift_idea = current_user.gift_ideas.new(gift_idea_params)

    # Budget validation
    if @gift_idea.event_recipient && !within_budget?(@gift_idea)
      @event_recipients = current_user.events.includes(event_recipients: :recipient).flat_map(&:event_recipients)
      flash.now[:alert] = "This gift exceeds the remaining budget for this event/recipient."
      render :new, status: :unprocessable_entity
      return
    end

    if @gift_idea.save
      redirect_to gift_ideas_path, notice: "#{@gift_idea.title} added!"
    else
      @event_recipients = current_user.events.includes(event_recipients: :recipient).flat_map(&:event_recipients)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event_recipients = current_user.events
                                    .includes(event_recipients: :recipient)
                                    .flat_map(&:event_recipients)
  end

  def update
    # Budget validation
    if @gift_idea.event_recipient && !within_budget?(@gift_idea, exclude_current: true)
      @event_recipients = current_user.events.includes(event_recipients: :recipient).flat_map(&:event_recipients)
      flash.now[:alert] = "This gift exceeds the remaining budget for this event/recipient."
      render :edit, status: :unprocessable_entity
      return
    end

    if @gift_idea.update(gift_idea_params)
      redirect_to gift_ideas_path, notice: "Gift updated."
    else
      @event_recipients = current_user.events.includes(event_recipients: :recipient).flat_map(&:event_recipients)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gift_idea.destroy

    respond_to do |format|
      format.html { redirect_to gift_ideas_path, notice: "Gift deleted successfully!" }
      format.json { render json: { success: true }, status: :ok }
    end
  end

  private

  def set_gift_idea
    @gift_idea = current_user.gift_ideas.find(params[:id])
  end

  def gift_idea_params
    params.require(:gift_idea).permit(:title, :price, :status, :url, :notes, :event_recipient_id)
  end

  def set_scope
    @scope = current_user
               .gift_ideas
               .includes(event_recipient: [:event, :recipient])
  end

  def within_budget?(gift_idea, exclude_current: false)
    return true unless gift_idea.price && gift_idea.event_recipient && gift_idea.price > 0

    event_recipient = gift_idea.event_recipient
    event = event_recipient.event

    # Check event-level budget
    if event.budget && event.budget > 0
      current_spent = event.total_spent
      current_spent -= gift_idea.price if exclude_current && gift_idea.persisted?

      return false if (current_spent + gift_idea.price) > event.budget
    end

    # Check recipient-level budget
    if event_recipient.budget && event_recipient.budget > 0
      recipient_spent = event_recipient.gift_ideas
                                       .where(status: ['purchased', 'delivered', 'wrapped'])
                                       .sum(:price)
      recipient_spent -= gift_idea.price if exclude_current && gift_idea.persisted?

      return false if (recipient_spent + gift_idea.price) > event_recipient.budget
    end

    true
  end
end
