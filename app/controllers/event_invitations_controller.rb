# Controller for managing event invitations
class EventInvitationsController < ApplicationController
  before_action :require_authorization

  def index
    @invitations = current_user
      .received_event_invitations
      .pending
      .includes(:event, :inviter)
  end
  def update
    invitation = current_user.received_event_invitations.find(params[:id])
    case params[:decision]
    when "accept"
      invitation.accepted!
      Attendee.find_or_create_by!(event: invitation.event, user: current_user) do |a|
                a.role = :viewer
      end
    when "decline"
      invitation.declined!
    end
    redirect_to events_path
  end
end