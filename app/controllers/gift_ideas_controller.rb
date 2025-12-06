class GiftIdeasController < ApplicationController
  before_action :require_authorization
  #before_action :set_gift_idea, only: [:show, :edit, :update, :destroy]
  #before_action :set_scope, only: [:list, :search]

  def new
    @gift_idea = GiftIdea.new(params[:gift_idea])
  end

  def show
    @gift_idea = GiftIdea.find(params[:event_recipient_id])
    redirect_to list_gifts_path
  end

  def create
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
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
    @gift_ideas = current_user.gift_ideas.order(:title) 
    render :list
  end

  def add
    @gift_idea = GiftIdea.new
    render :add
  end

  #def search
  #  query = params[:query].to_s.strip
  #  gifts = if query.present?
  #    pattern = "%#{query.downcase}%"
  #    @scope.where("LOWER(recipients.title) LIKE ?", pattern)
  #  else
  #    @scope.order(:name)
  #  end
  #  render json: {
  #    gifts: gifts.map { |r| 
  #    {
  #      event_recipient_id: r.event_recipient_id,
  #      title: r.title,
  #      status: r.status,
  #      url: r.url,
  #      notes: r.notes
  #    }
  #  }
  #  }, status: :ok
  #end

  #def edit
  #  render :edit(@gift_idea)
  #end

  #def update
  #  if @gift_idea.update(gift_idea_params)
  #    redirect_to list_gifts_path, notice: "Gift updated."
  #  else
  #    render :edit, status: :unprocessable_entity
  #  end
  #end

  #def destroy
  #  @gift_idea.destroy
  #  redirect_to list_gifts_path, notice: "Gift deleted."
  #end

  private
  #def set_gift
  #  @gift_idea = @current_user.gift_ideas.find(params[:event_recipient_id])
  #end

  def gift_idea_params
    params.require(:gift_idea).permit(:title, :price, :status, :url, :notes, :event_recipient_id, :commit)
  end

  #def set_scope
  #  @scope = current_user
  #    .gift_ideas
  #    .includes(:events, :recipients)
  #end
end
