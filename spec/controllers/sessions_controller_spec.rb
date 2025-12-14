require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) do
    User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  describe 'GET new' do
    it 'shows the login page' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'logs in with correct credentials and redirects to dashboard' do
      user
      post :create, params: { username: 'testuser', password: 'password123' }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(dashboard_path)
    end

    it 'rejects wrong credentials and renders new with status unauthorized' do
      user
      post :create, params: { username: 'testuser', password: 'wrong' }
      expect(session[:user_id]).to be_nil
      expect(flash[:invalid_credentials]).to be_present
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE destroy' do
    it 'clears session and redirects to login path' do
      session[:user_id] = user.id
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
    end
  end
end