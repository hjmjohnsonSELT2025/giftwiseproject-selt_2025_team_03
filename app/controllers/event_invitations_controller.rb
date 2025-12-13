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
    when "decline"
      invitation.declined!
    end
    redirect_to events_path
  end
end