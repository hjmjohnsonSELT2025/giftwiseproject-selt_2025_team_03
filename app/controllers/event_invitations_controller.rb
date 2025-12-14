# Controller for managing event invitations
class EventInvitationsController < ApplicationController
  before_action :require_authorization
  before_action :set_event, only: [:new, :create]

  def index
    @invitations = current_user
      .received_event_invitations
      .includes(:event, :inviter)
  end
  def update
    invitation = current_user.received_event_invitations.find(params[:id])
    EventInvitation.transaction do 
      case params[:decision]
      when "accept"
        Attendee.find_or_create_by!(event: invitation.event, user: current_user) do |a|
                    a.role = :viewer
        end
      when "decline"
      
      else 
        redirect_to events_path, alert: "Invalid decision."
        return
      end
      invitation.destroy!
    end
    redirect_to events_path, status: :see_other
  end
  def new
    invited_ids  = @event.event_invitations.select(:invitee_id)
    attendee_ids = @event.attendees.select(:user_id)

    @users = User
      .where(public_profile: true)
      .where.not(id: current_user.id)
      .where.not(id: invited_ids)
      .where.not(id: attendee_ids)
      .order(:username)
  end
  def create
    invitee = User.find_by(id: params[:invitee_id], public_profile: true)
    redirect_back(fallback_location: events_path, alert: "User not found.") and return unless invitee

    invitation = @event.event_invitations.new(inviter: current_user, invitee: invitee)

    if invitation.save
      redirect_to events_path, notice: "Invitation sent."
    else
      redirect_to events_path, alert: "Waiting on #{invitee.first_name} to accept/decline an existing invitation for this event."
    end
  end
  private
  def set_event
    event_id = params[:event_id] || params.dig(:event_invitation, :event_id)
    @event = current_user.owned_events.find_by(id: event_id)
    redirect_back(fallback_location: events_path, alert: "Not authorized to invite anyone for this event.") and return unless @event
  end
end