class RecipientsController < ApplicationController
  before_action :require_authorization
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]

  def index
    @recipients = current_user.recipients.order(:name)
  end


  def show
    
  end

  def new 
    @recipient = current_user.recipients.new
  end

  def create 
    @recipient = current_user.recipients.new(recipient_params)
    if @recipient.save
      redirect_to recipients_path, notice: "Recipient created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end
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
    @recipient = current_user.recipients.find(params[:id])
  end

  def recipient_params
    params.require(:recipient).permit(:name, :birthday, :relationship, :likes, :dislikes)
  end
end