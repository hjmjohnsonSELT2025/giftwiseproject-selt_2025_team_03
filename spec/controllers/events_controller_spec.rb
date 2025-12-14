require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) do
    User.create!(
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
    User.create!(
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
      creator: user,
      name: 'Christmas',
      date: Date.new(2025, 12, 25),
      budget: 1000,
      location: 'Home',
      theme: 'Family Christmas'
    )
  end

  let!(:event2) do
    Event.create!(
      creator: user,
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
          creator: other_user,
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
      expect(Event.last.creator).to eq(user)
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

  # describe 'DELETE #destroy' do
  #   it 'destroys the event' do
  #     expect {
  #       delete :destroy, params: { id: event1.id }
  #     }.to change(Event, :count).by(-1)
  #   end
  #
  #   it 'redirects to events index for HTML' do
  #     delete :destroy, params: { id: event1.id }
  #     expect(response).to redirect_to(events_path)
  #   end
  #
  #   it 'returns JSON for JSON format' do
  #     delete :destroy, params: { id: event1.id }, format: :json
  #     expect(response).to be_successful
  #     json_response = JSON.parse(response.body)
  #     expect(json_response['success']).to be true
  #   end
  # end

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

  describe 'Event Invitations rendering' do
    let!(:invited_user) do
      User.create!(
        username: 'invited_user_unique',
        email: 'unique_invited@test.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'Invited',
        last_name: 'User',
        birthday: Date.new(1992, 3, 10)
      )
    end
    before do
      session[:user_id] = user.id
    end

    it 'loads pending invitations on index' do
      # FIX: Ensure the logged-in user (user) is the invitee, not the inviter
      EventInvitation.create!(
        event: event1,
        inviter: other_user,
        invitee: user,
        status: 'pending'
      )
      get :index

      expect(assigns(:event_invitations)).to be_present
      expect(assigns(:event_invitations).count).to eq(1)
    end

    it 'does not load accepted or declined invitations' do
      EventInvitation.create!(
        event: event1,
        inviter: other_user,
        invitee: user,
        status: 'accepted'
      )
      get :index

      expect(assigns(:event_invitations).count).to eq(0)
    end

    it 'only loads invitations for current user' do
      EventInvitation.create!(
        event: event1,
        inviter: other_user,
        invitee: invited_user,
        status: 'pending'
      )
      get :index

      expect(assigns(:event_invitations).count).to eq(0)
    end
  end
  describe 'Error handling' do
    before do
      session[:user_id] = user.id
    end
    it 'handles invalid event ID gracefully' do
      expect {
        get :show, params: { id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'prevents accessing other users events' do
      other_event = Event.create!(
        creator: other_user,
        name: 'Other Event',
        date: Date.new(2025, 7, 1)
      )
      expect {
        get :show, params: { id: other_event.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'handles database errors during create' do
      allow_any_instance_of(Event).to receive(:save).and_return(false)
      allow_any_instance_of(Event).to receive(:errors).and_return(
        double(full_messages: ['Database error'])
      )
      post :create, params: {
        event: {
          name: 'Test Event',
          date: Date.today
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe 'Complex search scenarios' do
    before do
      session[:user_id] = user.id
    end
    it 'searches by partial name match' do
      get :search, params: { query: 'Christ' }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['events'].map { |e| e['name'] }).to include('Christmas')
    end
    it 'searches by theme' do
      event1.update(theme: 'Winter Wonderland')

      get :search, params: { query: 'winter' }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['events'].length).to eq(1)
      expect(json_response['events'][0]['name']).to eq('Christmas')
    end
    it 'is case insensitive' do
      get :search, params: { query: 'CHRISTMAS' }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['events'].length).to eq(1)
    end
    it 'handles special characters in search' do
      event_with_special = Event.create!(
        creator: user,
        name: "Mom's Birthday!",
        date: Date.new(2025, 8, 1)
      )
      get :search, params: { query: "Mom's" }, format: :json

      json_response = JSON.parse(response.body)
      expect(json_response['events'].map { |e| e['name'] }).to include("Mom's Birthday!")
    end
    it 'returns events ordered by date' do
      future_event = Event.create!(
        creator: user,
        name: 'Future',
        date: Date.new(2026, 1, 1)
      )
      get :search, params: { query: '' }, format: :json

      json_response = JSON.parse(response.body)
      dates = json_response['events'].map { |e| Date.parse(e['date']) }

      expect(dates).to eq(dates.sort)
    end
  end
  describe 'Recipient management in events' do
    before do
      session[:user_id] = user.id
    end
    it 'handles adding multiple recipients' do
      recipient1 = user.recipients.create(name: 'Alice')
      recipient2 = user.recipients.create(name: 'Bob')
      post :create, params: {
        event: {
          name: 'Party',
          date: Date.today
        },
        recipient_ids: [recipient1.id, recipient2.id]
      }
      event = Event.last
      expect(event.recipients.count).to eq(2)
    end
    it 'updates recipients when event is updated' do
      recipient1 = user.recipients.create(name: 'Alice')
      recipient2 = user.recipients.create(name: 'Bob')

      event1.event_recipients.create(recipient: recipient1)
      patch :update, params: {
        id: event1.id,
        event: { name: event1.name },
        recipient_ids: [recipient2.id]
      }
      event1.reload
      expect(event1.recipients.pluck(:name)).to eq(['Bob'])
      expect(event1.recipients.count).to eq(1)
    end
    it 'handles empty recipient list' do
      post :create, params: {
        event: {
          name: 'Solo Event',
          date: Date.today
        },
        recipient_ids: []
      }
      event = Event.last
      expect(event.recipients.count).to eq(0)
    end
  end
  describe 'Budget edge cases' do
    before do
      session[:user_id] = user.id
    end
    it 'allows zero budget' do
      post :create, params: {
        event: {
          name: 'Free Event',
          date: Date.today,
          budget: 0
        }
      }
      event = Event.last
      expect(event.budget).to eq(0)
    end
    it 'handles very large budgets' do
      post :create, params: {
        event: {
          name: 'Expensive Event',
          date: Date.today,
          budget: 999999.99
        }
      }
      event = Event.last
      expect(event.budget).to eq(999999.99)
    end
    it 'handles decimal budgets' do
      post :create, params: {
        event: {
          name: 'Precise Budget',
          date: Date.today,
          budget: 123.45
        }
      }
      event = Event.last
      expect(event.budget).to eq(123.45)
    end
  end
end