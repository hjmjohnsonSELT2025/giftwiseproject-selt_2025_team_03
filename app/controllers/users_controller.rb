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

      UserMailer.welcome_email(@user).deliver_later

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
    @last_query = params[:query].to_s.strip

    @event = nil
    if params[:event_id].present?
      @event = current_user.owned_events.find_by(id: params[:event_id])
      redirect_to(events_path, alert: "Not authorized to invite for this event.") and return unless @event
    end

    @users =
      if @last_query.present?
        User.where(public_profile: true)
            .where("LOWER(username) LIKE ?", "%#{@last_query.downcase}%")
            .where.not(id: current_user.id)
            .order(:username)
      else
        []
      end
      case request.headers["Turbo-Frame"]
      when "modal"
        render :find_modal
      when "users_list"
        invite_mode = @event.present?
        render partial: "users/find_results",
              
              locals: { users: @users, invite_event: @event, last_query: @last_query, clickable: true, show_actions: !invite_mode }
      else
        render :find
      end
  end


  def new_event_invitation
    @events = current_user.owned_events.order(:date)
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
    events = current_user.owned_events.where(id: event_ids)
    created_count = 0

    events.each do |evt|
      next if evt.attendees.exists?(user_id: @user.id)
      # delete old invites
      EventInvitation.where(event: evt, invitee: @user).delete_all
      EventInvitation.create!(event: evt, inviter: current_user, invitee: @user)
      created_count += 1
      end
    redirect_to events_path, notice: "Sent #{created_count} invitations to #{@user.first_name}"
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
    attrs = params.require(:user).permit(:username, :email, :password, :password_confirmation, :first_name, :last_name, :birthday, :public_profile, :likes, :dislikes, :email_notifications)
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end
    attrs
  end

end