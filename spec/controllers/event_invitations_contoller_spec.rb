require "rails_helper"

RSpec.describe EventInvitationsController, type: :controller do
  let(:inviter) do
    User.create!(
      email: "inviter@example.com",
      password: "password",
      username: "inviter_user",
      first_name: "Inviter",
      last_name: "User"
    )
  end

  let(:invitee) do
    User.create!(
      email: "invitee@example.com",
      password: "password",
      username: "invitee_user",
      first_name: "Invitee",
      last_name: "User"
    )
  end

  let!(:event) do
    Event.create!(
      name: "Test Event",
      user_id: inviter.id,
      date: Date.today + 1.week
    )
  end

  let!(:invitation) do
    EventInvitation.create!(
      event: event,
      inviter: inviter,
      invitee: invitee,
      status: "pending"
    )
  end

  before do
    routes.draw do
      resources :event_invitations, only: [:index, :update]
      get "/login", to: "sessions#new", as: :login
      get "/events", to: "events#index", as: :events
    end
  end

  describe "GET #index" do
    context "when logged in" do
      before { allow(controller).to receive(:current_user).and_return(invitee) }

      it "assigns pending received invitations" do
        get :index
        expect(assigns(:invitations)).to include(invitation)
      end

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "when not logged in" do
      before { allow(controller).to receive(:current_user).and_return(nil) }

      it "redirects to login_path" do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "PATCH #update" do
    context "when accepting an invitation" do
      before { allow(controller).to receive(:current_user).and_return(invitee) }

      it "marks the invitation as accepted" do
        patch :update, params: { id: invitation.id, decision: "accept" }
        expect(invitation.reload.status).to eq("accepted")
      end

      it "redirects to events_path" do
        patch :update, params: { id: invitation.id, decision: "accept" }
        expect(response).to redirect_to(events_path)
      end
    end

    context "when declining an invitation" do
      before { allow(controller).to receive(:current_user).and_return(invitee) }

      it "marks the invitation as declined" do
        patch :update, params: { id: invitation.id, decision: "decline" }
        expect(invitation.reload.status).to eq("declined")
      end

      it "redirects to events_path" do
        patch :update, params: { id: invitation.id, decision: "decline" }
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
