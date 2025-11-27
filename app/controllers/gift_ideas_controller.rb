class GiftIdeasController < ApplicationController
  def new
    @gift_idea = Gift_Idea.new(params[:gift_idea])
  end
  def show
    @gift_idea = Gift_Idea.find(params[:id])
    redirect_to list_gifts_path
  end
  def create
    @gift_idea = Gift_Idea.new(gift_idea_params)
    if @gift_idea.save
      session[:event_recipient_id] = @gift_idea.id
      redirect_to gift_idea_path(@user), notice: "Welcome, #{@user.username}!"
    else
      Rails.logger.warn "Failed to create a gift: #{user.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end
  def list
    render :list
  end
end
