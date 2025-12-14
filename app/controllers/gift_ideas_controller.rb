class GiftIdeasController < ApplicationController
  before_action :require_authorization
  before_action :set_gift_idea, only: [:show, :edit, :update, :destroy]
  before_action :set_scope, only: [:index, :search]
  before_action :load_event_recipients, only: [:new, :create, :edit, :update]

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
    @gift_idea = current_user.gift_ideas.build
  end

  def create
    @gift_idea = current_user.gift_ideas.new(gift_idea_params)

    if @gift_idea.save
      redirect_to gift_ideas_path, notice: "#{@gift_idea.title} added!"
    else
      if @gift_idea.errors.details[:base].any? { |error| error[:error] == :exceeds_budget }
        flash.now[:alert] = "This gift exceeds the remaining budget for this event/recipient."
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @gift_idea.update(gift_idea_params)
      redirect_to gift_ideas_path, notice: "Gift updated."
    else
      if @gift_idea.errors.details[:base].any? { |error| error[:error] == :exceeds_budget }
        flash.now[:alert] = "This gift exceeds the remaining budget for this event/recipient."
      end
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

  def load_event_recipients
    @event_recipients = EventRecipient.joins(:event)
                                      .where(events: { user_id: current_user.id })
                                      .includes(:recipient)
                                      .order('events.date ASC')
  end
end