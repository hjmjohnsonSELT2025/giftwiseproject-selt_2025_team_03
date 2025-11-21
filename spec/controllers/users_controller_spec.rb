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

    it 'rejects wrong password' do
      post :authorize, params: { login: 'testuser', password: 'wrong' }
      expect(session[:user_id]).to be_nil
      expect(flash[:alert]).to eq('Invalid username/email or password.')
    end

    it 'rejects nonexistent user' do
      post :authorize, params: { login: 'nobody', password: 'password123' }
      expect(session[:user_id]).to be_nil
    end
  end

  describe 'GET new' do
    it 'shows signup page' do
      get :new
      expect(response).to be_successful
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

    it 'redirects after signup' do
      post :create, params: {
        user: {
          username: 'newuser',
          email: 'new@example.com',
          password: 'password123',
          first_name: 'New',
          last_name: 'User'
        }
      }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Welcome, newuser')
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
  end

  describe 'POST check_email' do
    it 'returns true for available email' do
      post :check_email, params: { email: 'available@example.com' }
      json = JSON.parse(response.body)
      expect(json['available']).to be true
    end

    it 'returns false for taken email' do
      User.create(username: 'existing', email: 'taken@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
      post :check_email, params: { email: 'taken@example.com' }
      json = JSON.parse(response.body)
      expect(json['available']).to be false
    end
  end
end