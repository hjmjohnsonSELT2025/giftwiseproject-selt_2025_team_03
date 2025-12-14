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

      it 'calculates total spent from purchased and delivered gifts' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        user.gift_ideas.create(event_recipient: er, title: 'Gift 1', price: 50, status: 'purchased')
        user.gift_ideas.create(event_recipient: er, title: 'Gift 2', price: 75, status: 'delivered')
        user.gift_ideas.create(event_recipient: er, title: 'Gift 3', price: 100, status: 'idea')

        get :index
        expect(assigns(:total_spent)).to eq(125)
      end

      it 'calculates gifts purchased percentage' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        user.gift_ideas.create(event_recipient: er, title: 'Gift 1', price: 50, status: 'purchased')
        user.gift_ideas.create(event_recipient: er, title: 'Gift 2', price: 75, status: 'idea')

        get :index
        expect(assigns(:gifts_purchased_percentage)).to eq(50)
      end

      it 'handles zero total gifts for percentage calculation' do
        get :index
        expect(assigns(:gifts_purchased_percentage)).to eq(0)
      end

      it 'uses default period of 7 days' do
        get :index
        expect(assigns(:period)).to eq(7)
      end

      it 'uses custom period when provided' do
        get :index, params: { period: 30 }
        expect(assigns(:period)).to eq(30)
      end

      it 'calculates spending data for chart' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        gift = user.gift_ideas.create(event_recipient: er, title: 'Gift', price: 100, status: 'purchased')
        gift.update_column(:updated_at, 3.days.ago)

        get :index
        spending_data = assigns(:spending_data)
        expect(spending_data).to be_a(Hash)
        expect(spending_data.values.last).to eq(100)
      end
    end

    context 'JSON response' do
      before do
        session[:user_id] = user.id
      end

      it 'returns spending data as JSON' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        user.gift_ideas.create(event_recipient: er, title: 'Gift', price: 50, status: 'purchased')

        get :index, params: { period: 7 }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response).to be_a(Hash)
      end

      it 'returns correct cumulative spending data' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        gift1 = user.gift_ideas.create(event_recipient: er, title: 'Gift 1', price: 50, status: 'purchased')
        gift1.update_column(:updated_at, 2.days.ago)

        gift2 = user.gift_ideas.create(event_recipient: er, title: 'Gift 2', price: 30, status: 'delivered')
        gift2.update_column(:updated_at, 1.day.ago)

        get :index, params: { period: 7 }, format: :json

        json_response = JSON.parse(response.body)
        values = json_response.values

        # Should be cumulative
        expect(values.last).to eq(80)
      end
    end

    context 'calculate_spending_by_day edge cases' do
      before do
        session[:user_id] = user.id
      end

      it 'handles period with no purchases' do
        get :index, params: { period: 7 }

        spending_data = assigns(:spending_data)
        expect(spending_data.values).to all(eq(0))
      end

      it 'handles purchases outside date range' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        gift = user.gift_ideas.create(event_recipient: er, title: 'Old Gift', price: 100, status: 'purchased')
        gift.update_column(:updated_at, 30.days.ago)

        get :index, params: { period: 7 }

        spending_data = assigns(:spending_data)
        expect(spending_data.values).to all(eq(0))
      end

      it 'ignores gifts that are not purchased or delivered' do
        event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
        recipient = user.recipients.create(name: 'Mom')
        er = event.event_recipients.create(recipient: recipient)

        user.gift_ideas.create(event_recipient: er, title: 'Idea', price: 100, status: 'idea')
        user.gift_ideas.create(event_recipient: er, title: 'Backlogged', price: 50, status: 'backlogged')

        get :index, params: { period: 7 }

        spending_data = assigns(:spending_data)
        expect(spending_data.values).to all(eq(0))
      end
    end
  end
end