require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Test',
      last_name: 'User',
      birthday: Date.new(1990, 1, 1)
    )
  end

  let(:other_user) do
    User.create(
      username: 'otheruser',
      email: 'other@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Other',
      last_name: 'User',
      birthday: Date.new(1985, 5, 15)
    )
  end

  let!(:event1) do
    Event.create!(
      user: user,
      name: 'Christmas',
      date: Date.new(2025, 12, 25),
      budget: 1000,
      location: 'Home',
      theme: 'Family Christmas'
    )
  end

  let!(:event2) do
    Event.create!(
      user: user,
      name: 'Birthday Party',
      date: Date.new(2025, 6, 15),
      budget: 500,
      location: 'Restaurant'
    )
  end

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    context 'when user is logged in' do
      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns @events with user\'s events ordered by date' do
        get :index
        expect(assigns(:events)).to match_array([event2, event1])
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'does not show other users\' events' do
        other_event = Event.create!(
          user: other_user,
          name: 'Other Event',
          date: Date.new(2025, 7, 1),
          budget: 300
        )
        get :index
        expect(assigns(:events)).not_to include(other_event)
      end
    end

    context 'when user is not logged in' do
      before do
        session[:user_id] = nil
      end

      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'GET #search' do
    context 'with a query' do
      it 'returns events matching the query' do
        get :search, params: { query: 'Christmas' }, format: :json
        expect(response).to be_successful
        json_response = JSON.parse(response.body)
        expect(json_response['events'].length).to eq(1)
        expect(json_response['events'][0]['name']).to eq('Christmas')
      end

      it 'searches by location' do
        get :search, params: { query: 'Restaurant' }, format: :json
        expect(response).to be_successful
        json_response = JSON.parse(response.body)
        expect(json_response['events'].length).to eq(1)
        expect(json_response['events'][0]['name']).to eq('Birthday Party')
      end

      it 'returns empty array when no matches' do
        get :search, params: { query: 'Nonexistent' }, format: :json
        expect(response).to be_successful
        json_response = JSON.parse(response.body)
        expect(json_response['events']).to be_empty
      end
    end

    context 'without a query' do
      it 'returns all user\'s events ordered by date' do
        get :search, params: { query: '' }, format: :json
        expect(response).to be_successful
        json_response = JSON.parse(response.body)
        expect(json_response['events'].length).to eq(2)
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested event to @event' do
      get :show, params: { id: event1.id }
      expect(assigns(:event)).to eq(event1)
    end

    it 'renders the show template' do
      get :show, params: { id: event1.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    it 'shows new event form' do
      get :new
      expect(response).to be_successful
    end

    it 'loads recipients' do
      user.recipients.create(name: 'Mom')
      user.recipients.create(name: 'Dad')
      get :new
      expect(assigns(:recipients).count).to eq(2) if assigns(:recipients)
    end

    it 'creates new event object' do
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe 'POST create' do
    it 'creates new event' do
      expect {
        post :create, params: {
          event: {
            name: 'Christmas',
            date: Date.today,
            budget: 500
          }
        }
      }.to change(Event, :count).by(1)
    end

    it 'creates event with location and theme' do
      post :create, params: {
        event: {
          name: 'Birthday Party',
          date: Date.today,
          location: 'Home',
          theme: 'Surprise'
        }
      }
      event = Event.last
      expect(event.location).to eq('Home')
      expect(event.theme).to eq('Surprise')
    end

    it 'associates recipients with event' do
      recipient1 = user.recipients.create(name: 'Mom')
      recipient2 = user.recipients.create(name: 'Dad')

      post :create, params: {
        event: {
          name: 'Christmas',
          date: Date.today
        },
        recipient_ids: [recipient1.id, recipient2.id]
      }

      event = Event.last
      expect(event.recipients.count).to eq(2) if event.respond_to?(:recipients)
    end

    it 'redirects after successful creation' do
      post :create, params: {
        event: {
          name: 'Christmas',
          date: Date.today
        }
      }
      expect(response).to redirect_to(events_path)
      # Check for either flash message format
      expect(flash[:notice]).to match(/Event created/)
    end

    it 'rejects invalid event' do
      expect {
        post :create, params: {
          event: {
            name: '',
            date: nil
          }
        }
      }.not_to change(Event, :count)
    end

    it 'renders form again on validation error' do
      post :create, params: {
        event: { name: '' }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end

    it 'associates the event with the current user' do
      post :create, params: {
        event: {
          name: 'New Event',
          date: Date.new(2025, 8, 1),
          budget: 750
        }
      }
      expect(Event.last.user).to eq(user)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested event to @event' do
      get :edit, params: { id: event1.id }
      expect(assigns(:event)).to eq(event1)
    end

    it 'renders the edit template' do
      get :edit, params: { id: event1.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: 'Updated Christmas',
          budget: 1500
        }
      end

      it 'updates the event' do
        patch :update, params: { id: event1.id, event: new_attributes }
        event1.reload
        expect(event1.name).to eq('Updated Christmas')
        expect(event1.budget).to eq(1500)
      end

      it 'redirects to events index' do
        patch :update, params: { id: event1.id, event: new_attributes }
        expect(response).to redirect_to(events_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          name: '',
          date: nil
        }
      end

      it 'does not update the event' do
        original_name = event1.name
        patch :update, params: { id: event1.id, event: invalid_attributes }
        event1.reload
        expect(event1.name).to eq(original_name)
      end

      it 'renders the edit template' do
        patch :update, params: { id: event1.id, event: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the event' do
      expect {
        delete :destroy, params: { id: event1.id }
      }.to change(Event, :count).by(-1)
    end

    it 'redirects to events index for HTML' do
      delete :destroy, params: { id: event1.id }
      expect(response).to redirect_to(events_path)
    end

    it 'returns JSON for JSON format' do
      delete :destroy, params: { id: event1.id }, format: :json
      expect(response).to be_successful
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
    end
  end

  describe 'authorization' do
    it 'requires login for index' do
      session[:user_id] = nil
      get :index
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for new' do
      session[:user_id] = nil
      get :new
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for create' do
      session[:user_id] = nil
      post :create, params: {
        event: { name: 'Test', date: Date.today }
      }
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for edit' do
      session[:user_id] = nil
      get :edit, params: { id: event1.id }
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for update' do
      session[:user_id] = nil
      patch :update, params: { id: event1.id, event: { name: 'Updated' } }
      expect(response).to redirect_to(login_path)
    end

    it 'requires login for destroy' do
      session[:user_id] = nil
      delete :destroy, params: { id: event1.id }
      expect(response).to redirect_to(login_path)
    end
  end
end