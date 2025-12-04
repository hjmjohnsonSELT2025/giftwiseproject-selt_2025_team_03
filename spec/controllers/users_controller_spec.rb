require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET login' do
    it 'shows login page' do
      get :login
      expect(response).to be_successful
    end
  end

  describe 'POST authorize' do
    let(:user) do
      User.create(
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        first_name: 'Test',
        last_name: 'User'
      )
    end

    it 'logs in with correct credentials' do
      user
      post :authorize, params: { username: 'testuser', password: 'password123' }
      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(dashboard_path)
    end

    it 'rejects wrong password' do
      user
      post :authorize, params: { username: 'testuser', password: 'wrong' }
      expect(session[:user_id]).to be_nil
      expect(flash[:alert]).to eq('Invalid username/password.')
    end

    it 'rejects nonexistent user' do
      post :authorize, params: { username: 'nobody', password: 'password123' }
      expect(session[:user_id]).to be_nil
    end

    it 'is case insensitive for username' do
      user
      post :authorize, params: { username: 'TESTUSER', password: 'password123' }
      expect(session[:user_id]).to eq(user.id)
    end
  end

  describe 'GET new' do
    it 'shows signup page' do
      get :new
      expect(response).to be_successful
    end

    it 'creates new user object' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST create' do
    it 'creates new user' do
      expect {
        post :create, params: {
          user: {
            username: 'newuser',
            email: 'new@example.com',
            password: 'password123',
            first_name: 'New',
            last_name: 'User'
          }
        }
      }.to change(User, :count).by(1)
    end

    it 'redirects to dashboard after signup' do
      post :create, params: {
        user: {
          username: 'newuser',
          email: 'new@example.com',
          password: 'password123',
          first_name: 'New',
          last_name: 'User'
        }
      }
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:notice]).to eq('Welcome, newuser!')
    end

    it 'logs user in after signup' do
      post :create, params: {
        user: {
          username: 'newuser',
          email: 'new@example.com',
          password: 'password123',
          first_name: 'New',
          last_name: 'User'
        }
      }
      expect(session[:user_id]).not_to be_nil
    end

    it 'rejects invalid user' do
      expect {
        post :create, params: {
          user: {
            username: '',
            email: 'bad',
            password: '123'
          }
        }
      }.not_to change(User, :count)
    end

    it 'renders new template on error' do
      post :create, params: {
        user: { username: '' }
      }
      expect(response).to render_template(:new)
    end
  end

  describe 'DELETE logout' do
    it 'clears session' do
      user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
      session[:user_id] = user.id
      delete :logout
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root' do
      user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
      session[:user_id] = user.id
      delete :logout
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST check_email' do
    it 'returns available for new email' do
      post :check_email, params: { email: 'available@example.com' }
      json = JSON.parse(response.body)
      expect(json['available']).to be true
      expect(response).to have_http_status(:ok)
    end

    it 'returns unavailable for taken email' do
      User.create(username: 'existing', email: 'taken@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
      post :check_email, params: { email: 'taken@example.com' }
      json = JSON.parse(response.body)
      expect(json['available']).to be false
      expect(response).to have_http_status(:conflict)
    end

    it 'is case insensitive' do
      User.create(username: 'existing', email: 'taken@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
      post :check_email, params: { email: 'TAKEN@EXAMPLE.COM' }
      json = JSON.parse(response.body)
      expect(json['available']).to be false
    end
  end
end