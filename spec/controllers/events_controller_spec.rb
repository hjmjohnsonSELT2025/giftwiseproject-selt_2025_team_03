require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  before do
    session[:user_id] = user.id
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
      expect(assigns(:recipients).count).to eq(2)
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
      expect(event.recipients.count).to eq(2)
    end

    it 'redirects after successful creation' do
      post :create, params: {
        event: {
          name: 'Christmas',
          date: Date.today
        }
      }
      expect(response).to redirect_to(events_path)
      expect(flash[:notice]).to eq('Event created successfully!')
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
  end

  describe 'authorization' do
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
  end
end