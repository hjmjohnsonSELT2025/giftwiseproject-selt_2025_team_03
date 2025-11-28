class GiftIdeasController < ApplicationController
  def new
    @gift_idea = GiftIdea.new(params[:gift_idea])
  end
  def show
    @gift_idea = GiftIdea.find(params[:event_recipient_id])
    redirect_to list_gifts_path
  end
  def create
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @gift_idea = current_user.gift_ideas.new(gift_idea_params)
    if @gift_idea.save
      session[:event_recipient_id] = @gift_idea.event_recipient_id
      redirect_to list_gifts_path(@gift_idea), notice: "#{@gift_idea.title} added!"
    else
      Rails.logger.warn "Failed to create a gift: #{@gift_idea.errors.full_messages.to_sentence}"
      render :add, status: :unprocessable_entity
    end
  end
  def list
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @upcoming_gifts = current_user.gift_ideas
    render :list
  end
  def add
    @gift_idea = GiftIdea.new
    render :add
  end

  private
  def gift_idea_params
    params.require(:gift_idea).permit(:title, :price, :status, :url, :notes, :event_recipient_id, :commit)
  end
end
