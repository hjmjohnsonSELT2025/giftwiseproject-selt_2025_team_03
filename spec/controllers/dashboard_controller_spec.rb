require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  describe 'GET index' do
    context 'when not logged in' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'shows dashboard' do
        get :index
        expect(response).to be_successful
      end

      it 'loads user data' do
        get :index
        expect(assigns(:user)).to eq(user)
      end

      it 'loads upcoming events' do
        user.events.create(name: 'Future', date: 2.days.from_now)
        user.events.create(name: 'Past', date: 2.days.ago)
        get :index
        expect(assigns(:upcoming_events).count).to eq(1)
      end

      it 'calculates total events' do
        user.events.create(name: 'Event 1', date: Date.today)
        user.events.create(name: 'Event 2', date: Date.today)
        get :index
        expect(assigns(:total_events)).to eq(2)
      end

      it 'calculates total recipients' do
        user.recipients.create(name: 'Mom')
        user.recipients.create(name: 'Dad')
        get :index
        expect(assigns(:total_recipients)).to eq(2)
      end

      it 'calculates total budget' do
        user.events.create(name: 'Event 1', date: Date.today, budget: 100)
        user.events.create(name: 'Event 2', date: Date.today, budget: 200)
        get :index
        expect(assigns(:total_budget)).to eq(300)
      end
    end
  end
end