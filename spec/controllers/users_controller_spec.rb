require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:current_user) do
    User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'T',
      last_name: 'U'
    )
  end
  before { session[:user_id] = current_user.id }

  describe 'GET new' do
    it 'shows signup page and creates new user object' do
      get :new
      expect(response).to be_successful
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST create' do
    let(:valid_params) do
      {
        username: 'newuser', email: 'new@example.com', password: 'password123', password_confirmation: 'password123',
        first_name: 'New', last_name: 'User', likes: 'reading', public_profile: true
      }
    end

    it 'creates new user, logs them in, and redirects' do
      expect {
        post :create, params: { user: valid_params }
      }.to change(User, :count).by(1)

      expect(session[:user_id]).not_to be_nil
      expect(response).to redirect_to(dashboard_path)
    end

    it 'renders new template on invalid submission' do
      post :create, params: { user: { username: '', first_name: 'A', last_name: 'B' } }
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST check_email' do
    it 'returns available for new email and unavailable for taken email' do
      User.create!(username: 'existing', email: 'taken@example.com', password: 'p', password_confirmation: 'p', first_name: 'T', last_name: 'U')

      post :check_email, params: { email: 'available@example.com' }
      expect(JSON.parse(response.body)['available']).to be true

      post :check_email, params: { email: 'taken@example.com' }
      expect(JSON.parse(response.body)['available']).to be false
    end
  end

  describe 'GET edit' do
    it 'shows edit profile page for logged in user' do
      get :edit
      expect(response).to be_successful
      expect(assigns(:user)).to eq(current_user)
    end
  end

  describe 'PATCH update' do
    it 'updates user profile and redirects' do
      patch :update, params: { user: { first_name: 'Updated', public_profile: true } }
      current_user.reload
      expect(current_user.first_name).to eq('Updated')
      expect(response).to redirect_to(dashboard_path)
    end

    it 'renders edit on validation error' do
      patch :update, params: { user: { first_name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET find' do
    let!(:public_user) { User.create!(username: 'publicuser', email: 'p@example.com', password: 'p', password_confirmation: 'p', first_name: 'P', last_name: 'U', public_profile: true) }
    let!(:private_user) { User.create!(username: 'privateuser', email: 'pr@example.com', password: 'p', password_confirmation: 'p', first_name: 'Pr', last_name: 'U', public_profile: false) }

    it 'searches for public users only, excluding current user' do
      get :find, params: { query: 'user' }

      expect(assigns(:users)).to include(public_user)
      expect(assigns(:users)).not_to include(private_user)
      expect(assigns(:users)).not_to include(current_user)
    end

    it 'returns nil users when query is blank' do
      get :find, params: { query: '' }
      expect(assigns(:users)).to be_nil
    end
  end

  describe 'POST create_event_invitation' do
    let!(:target_user) { User.create!(username: 'target', email: 't@example.com', password: 'p', password_confirmation: 'p', first_name: 'T', last_name: 'U', public_profile: true) }
    let!(:event) { current_user.events.create!(name: 'Party', date: Date.today) }

    it 'creates event invitation and redirects' do
      expect {
        post :create_event_invitation, params: { id: target_user.id, event_ids: [event.id] }
      }.to change(EventInvitation, :count).by(1)

      expect(response).to redirect_to(events_path)
      expect(flash[:notice]).to be_present
    end

    it 'does not create duplicate invitations' do
      EventInvitation.create!(event: event, inviter: current_user, invitee: target_user, status: 'pending')

      expect {
        post :create_event_invitation, params: { id: target_user.id, event_ids: [event.id] }
      }.not_to change(EventInvitation, :count)
    end
  end
end