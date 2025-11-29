require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "redirects to login when not logged in" do
      get "/dashboard"
      expect(response).to redirect_to(login_path)
    end
  end
end