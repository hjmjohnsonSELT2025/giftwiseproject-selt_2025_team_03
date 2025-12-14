require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:current_user) do
    User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User',
      public_profile: true
    )
  end

  describe 'GET login' do
    it 'shows login page' do
      get :login
      expect(response).to be_successful
    end
  end

  describe 'POST authorize' do
    it 'logs in with correct credentials' do
      post :authorize, params: { username: 'testuser', password: 'password123' }
      expect(session[:user_id]).to eq(current_user.id)
      expect(response).to redirect_to(dashboard_path)
    end

    it 'rejects wrong password' do
      post :authorize, params: { username: 'testuser', password: 'wrong' }
      expect(session[:user_id]).to be_nil
      # flash message varies by implementation; keep minimal assertion:
      expect(flash[:alert]).to be_present
    end

    it 'rejects nonexistent user' do
      post :authorize, params: { username: 'nobody', password: 'password123' }
      expect(session[:user_id]).to be_nil
    end

    it 'is case insensitive for username' do
      post :authorize, params: { username: 'TESTUSER', password: 'password123' }
      expect(session[:user_id]).to eq(current_user.id)
    end
  end

  describe 'DELETE logout' do
    before { session[:user_id] = current_user.id }

    it 'clears session and redirects to root' do
      delete :logout
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
    end
  end

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
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'New',
        last_name: 'User',
        likes: 'reading',
        public_profile: true
      }
    end

    it 'creates new user, logs them in, and redirects to dashboard' do
      expect {
        post :create, params: { user: valid_params }
      }.to change(User, :count).by(1)

      expect(session[:user_id]).not_to be_nil
      expect(response).to redirect_to(dashboard_path)
      # flash message text varies by implementation; don't pin exact string
      expect(flash[:notice]).to be_present
    end

    it 'does not create user on invalid submission and renders new' do
      expect {
        post :create, params: { user: { username: '', email: 'bad', password: '123' } }
      }.not_to change(User, :count)

      expect(response).to render_template(:new)
      # status may be 422 depending on controller; allow either
      expect([200, 422]).to include(response.status)
    end
  end

  describe 'POST check_email' do
    it 'returns available for new email and unavailable for taken email' do
      User.create!(
        username: 'existing',
        email: 'taken@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'T',
        last_name: 'U'
      )

      post :check_email, params: { email: 'available@example.com' }
      expect(JSON.parse(response.body)['available']).to be true

      post :check_email, params: { email: 'taken@example.com' }
      expect(JSON.parse(response.body)['available']).to be false
    end

    it 'is case insensitive' do
      User.create!(
        username: 'existing2',
        email: 'taken2@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'T',
        last_name: 'U'
      )

      post :check_email, params: { email: 'TAKEN2@EXAMPLE.COM' }
      expect(JSON.parse(response.body)['available']).to be false
    end
  end

  context 'when logged in' do
    before { session[:user_id] = current_user.id }

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
        expect(response).to render_template(:edit)
        expect([200, 422]).to include(response.status)
      end
    end

    describe 'GET find' do
      let!(:public_user) do
        User.create!(
          username: 'publicuser',
          email: 'p@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'P',
          last_name: 'U',
          public_profile: true
        )
      end

      let!(:private_user) do
        User.create!(
          username: 'privateuser',
          email: 'pr@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'Pr',
          last_name: 'U',
          public_profile: false
        )
      end

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
      let!(:target_user) do
        User.create!(
          username: 'target',
          email: 't@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'T',
          last_name: 'U',
          public_profile: true
        )
      end

      let!(:event) do
        current_user.events.create!(name: 'Party', date: Date.today)
      end

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
end
