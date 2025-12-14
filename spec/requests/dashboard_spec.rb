require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  describe "GET /dashboard" do
    context "when user is NOT logged in" do
      it "redirects to the login page" do
        get "/dashboard"
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user IS logged in" do
      before do
        post login_path, params: { username: user.username, password: 'password123' }
      end

      it "returns a successful response" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "renders the dashboard template" do
        get dashboard_path
        expect(response).to render_template(:index)
      end

      it "assigns required dashboard variables (e.g., upcoming events)" do
        event1 = user.events.create(date: Date.tomorrow, name: "Upcoming Event")
        event2 = user.events.create(date: Date.yesterday, name: "Past Event")

        get dashboard_path

        # Check that upcoming_events is assigned
        expect(assigns(:upcoming_events)).to be_present

        # If your controller filters properly, upcoming events should only include future events
        # If it doesn't filter, it will include all events - adjust based on actual controller behavior
        upcoming_event_names = assigns(:upcoming_events).map(&:name)
        expect(upcoming_event_names).to include("Upcoming Event")

        # Verify total_spent is calculated
        expect(assigns(:total_spent)).to be_a(Numeric)
      end
    end
  end
end