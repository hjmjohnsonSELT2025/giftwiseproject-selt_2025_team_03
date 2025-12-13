class UsersController < ApplicationController
  before_action :require_authorization, except: [:new, :create]
  before_action :set_user, only: [:show, :new_event_invitation, :create_event_invitation]
  before_action :ensure_profile_visible!, only: :show

  def show
    
    redirect_to dashboard_path
  end
  def edit
    @user = current_user
  end
  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to dashboard_path, notice: "Profile updated."
    else
      Rails.logger.debug "Invalid credentials received."
      render :edit, status: :unprocessable_entity, alert: "Invalid username/password."
    end
  end
  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Welcome, #{@user.username}!"
    else
      Rails.logger.warn "Failed to create an account: #{@user.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end
  def check_email
    email = params[:email].to_s.strip.downcase
    if User.exists?(email: email)
      render json: {
        available: false
      }, :status => :conflict
    else
      render json: {available: true}, :status => :ok
    end
  end
  def find
    if params[:query].present?
      @last_query = params[:query]
      q = "%#{params[:query].downcase}%"
      @users = User
                   .where(public_profile: true)
                   .where("LOWER(username) LIKE ?", q)
                   .where.not(id: current_user.id)
    else
      @users = nil
    end
  end

  def new_event_invitation
    @events = current_user.events.order(:date)
  end

  def create_event_invitation
    Rails.logger.info "[UsersController#create_event_invitation] params=#{params.to_unsafe_h.inspect}"
    if @user == current_user
            redirect_to find_users_path, alert: "You're already invited to your own event."
            return
    end
    
    event_ids = Array(params[:event_ids]).reject(&:blank?)
    if event_ids.empty?
            redirect_to new_event_invitation_user_path(@user),
            alert: "Please select at least one event."
            return
    end
    events = current_user.events.where(id: event_ids)
    created_count = 0

    events.each do |evt|
      invitation = EventInvitation.find_or_initialize_by(event: evt, invitee: @user)
      invitation.inviter = current_user
      invitation.status  = :pending
      invitation.save!
      created_count += 1 if invitation.previously_new_record?
    end
    
    if created_count > 0
            message = "Sent #{created_count} invitation#{'s' if created_count != 1}"
            
    else
      message = "No new invitations created, however, they may already exist."
    end

    redirect_to events_path, notice: message
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
  def ensure_profile_visible!
      return if @user == current_user
      #return if @user.public_profile?
      render status: :forbidden
  end
  def user_params
    attrs = params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name, :birthday, :public_profile, :likes, :dislikes)
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end
    attrs
  end

end