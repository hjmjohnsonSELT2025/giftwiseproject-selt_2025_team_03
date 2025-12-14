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

  describe 'Authentication' do
    shared_examples 'requires login' do |method, action, params = {}|
      before { session[:user_id] = nil }
      it "redirects #{method.to_s.upcase} #{action} to login page" do
        send(method, action, params: params)
        expect(response).to redirect_to(login_path)
      end
    end

    include_examples 'requires login', :get, :index
    include_examples 'requires login', :get, :new
    include_examples 'requires login', :post, :create, { event: { name: 'T', date: Date.today } }
    include_examples 'requires login', :get, :edit, { id: :event1 }
    include_examples 'requires login', :patch, :update, { id: :event1, event: { name: 'U' } }
    include_examples 'requires login', :delete, :destroy, { id: :event1 }
  end

  describe 'GET #index' do
    it 'returns successful, orders by date, and limits to current user' do
      other_event = Event.create!(creator: other_user, name: 'Other Event', date: Date.new(2025, 7, 1), budget: 300)

      get :index

      expect(response).to be_successful
      expect(response).to render_template(:index)
      expect(assigns(:events)).to eq([event2, event1])
      expect(assigns(:events)).not_to include(other_event)
    end
  end

  describe 'GET #search (JSON)' do
    it 'returns matching events by name, location, or theme, and is case insensitive' do
      event1.update(theme: 'Winter Wonderland')

      # Match by Name (case insensitive)
      get :search, params: { query: 'CHRISTMAS' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['events'].map { |e| e['name'] }).to include('Christmas')
      expect(json_response['events'].length).to eq(1)

      # Match by Location
      get :search, params: { query: 'Restaurant' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['events'][0]['name']).to eq('Birthday Party')

      # Match by Theme
      get :search, params: { query: 'winter' }, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response['events'][0]['name']).to eq('Christmas')
    end

    it 'handles no query or no matches' do
      get :search, params: { query: 'Nonexistent' }, format: :json
      expect(JSON.parse(response.body)['events']).to be_empty
    end
  end

  describe 'GET #show' do
    it 'assigns the requested event to @event and renders show' do
      get :show, params: { id: event1.id }
      expect(assigns(:event)).to eq(event1)
      expect(response).to render_template(:show)
    end

    it 'raises RecordNotFound if accessing other user\'s event' do
      other_event = Event.create!(creator: other_user, name: 'Other Event', date: Date.new(2025, 7, 1))
      expect {
        get :show, params: { id: other_event.id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #new' do
    it 'shows form, creates new event object, and loads recipients' do
      user.recipients.create(name: 'Mom')
      get :new
      expect(response).to be_successful
      expect(assigns(:event)).to be_a_new(Event)
      expect(assigns(:recipients)).to be_present
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      { name: 'New Year', date: Date.new(2026, 1, 1), budget: 123.45, location: 'City', theme: 'Gala' }
    end

    it 'creates new event with details, associates with user/recipients, and redirects' do
      recipient1 = user.recipients.create(name: 'Mom')
      expect {
        post :create, params: { event: valid_params, recipient_ids: [recipient1.id] }
      }.to change(Event, :count).by(1)

      event = Event.last
      expect(event.creator).to eq(user)
      expect(event.budget).to eq(123.45)
      expect(event.location).to eq('City')
      expect(event.recipients).to include(recipient1)
      expect(response).to redirect_to(events_path)
      expect(flash[:notice]).to match(/Event created/)
    end

    it 'handles zero budget and empty recipient list' do
      post :create, params: { event: valid_params.merge(budget: 0), recipient_ids: [] }
      event = Event.last
      expect(event.budget).to eq(0)
      expect(event.recipients.count).to eq(0)
    end

    it 'rejects invalid event and renders form' do
      expect {
        post :create, params: { event: { name: '', date: nil } }
      }.not_to change(Event, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end
  end

  describe 'PATCH #update' do
    it 'updates event attributes and redirects' do
      patch :update, params: { id: event1.id, event: { name: 'Updated Christmas', budget: 1500.00 } }
      event1.reload
      expect(event1.name).to eq('Updated Christmas')
      expect(event1.budget).to eq(1500.00)
      expect(response).to redirect_to(events_path)
    end

    it 'updates associated recipients' do
      recipient1 = user.recipients.create(name: 'Alice')
      recipient2 = user.recipients.create(name: 'Bob')
      event1.event_recipients.create(recipient: recipient1)

      patch :update, params: {
        id: event1.id,
        event: { name: event1.name },
        recipient_ids: [recipient2.id]
      }
      event1.reload
      expect(event1.recipients.pluck(:name)).to contain_exactly('Bob')
    end

    it 'rejects invalid parameters and renders edit template' do
      original_name = event1.name
      patch :update, params: { id: event1.id, event: { name: '' } }
      event1.reload
      expect(event1.name).to eq(original_name)
      expect(response).to render_template(:edit)
    end
  end

  describe 'Event Invitations' do
    let!(:invited_user) do
      User.create!(username: 'invited', email: 'i@t.com', password: 'p', password_confirmation: 'p', first_name: 'I', last_name: 'U')
    end

    it 'loads only pending invitations for current user on index' do
      # Pending for current user
      EventInvitation.create!(event: event1, inviter: other_user, invitee: user, status: 'pending')
      # Accepted for current user (should be excluded)
      EventInvitation.create!(event: event2, inviter: other_user, invitee: user, status: 'accepted')
      # Pending for another user (should be excluded)
      EventInvitation.create!(event: event1, inviter: user, invitee: invited_user, status: 'pending')

      get :index

      expect(assigns(:event_invitations)).to be_present
      expect(assigns(:event_invitations).count).to eq(1)
      expect(assigns(:event_invitations).first.event).to eq(event1)
    end
  end

  describe 'Error Handling and Edge Cases' do
    it 'handles invalid event ID gracefully' do
      expect {
        get :show, params: { id: 99999 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'handles database errors during create' do
      allow_any_instance_of(Event).to receive(:save).and_return(false)
      allow_any_instance_of(Event).to receive(:errors).and_return(double(full_messages: ['Database error']))
      post :create, params: { event: { name: 'Test', date: Date.today } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end