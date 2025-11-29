require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User') }

  describe 'validations' do
    it 'is valid with name and date' do
      event = user.events.create(name: 'Christmas', date: Date.today)
      expect(event).to be_valid
    end

    it 'requires a name' do
      event = user.events.new(date: Date.today)
      expect(event).not_to be_valid
    end

    it 'requires a date' do
      event = user.events.new(name: 'Birthday')
      expect(event).not_to be_valid
    end

    it 'allows budget to be nil' do
      event = user.events.create(name: 'Party', date: Date.today, budget: nil)
      expect(event).to be_valid
    end

    it 'rejects negative budget' do
      event = user.events.new(name: 'Party', date: Date.today, budget: -50)
      expect(event).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      event = user.events.create(name: 'Christmas', date: Date.today)
      expect(event.user).to eq(user)
    end

    it 'can have recipients' do
      event = user.events.create(name: 'Christmas', date: Date.today)
      recipient = user.recipients.create(name: 'Mom')
      event.recipients << recipient
      expect(event.recipients.count).to eq(1)
    end
  end

  describe 'scopes' do
    before do
      user.events.create(name: 'Past Event', date: 2.days.ago)
      user.events.create(name: 'Future Event', date: 2.days.from_now)
      user.events.create(name: 'Today Event', date: Date.today)
    end

    it 'finds upcoming events' do
      upcoming = user.events.upcoming
      expect(upcoming.count).to eq(2)
    end

    it 'finds past events' do
      past = user.events.past
      expect(past.count).to eq(1)
    end
  end

  describe '#days_until' do
    it 'calculates days until event' do
      event = user.events.create(name: 'Future', date: 5.days.from_now.to_date)
      expect(event.days_until).to be_between(4, 6)
    end

    it 'returns negative for past events' do
      event = user.events.create(name: 'Past', date: 3.days.ago.to_date)
      expect(event.days_until).to be < 0
    end
  end

  describe '#total_spent' do
    it 'calculates total from purchased gifts' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
      recipient = user.recipients.create(name: 'Mom')
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Gift 1', price: 50, status: 'purchased')
      er.gift_ideas.create(title: 'Gift 2', price: 75, status: 'purchased')
      er.gift_ideas.create(title: 'Gift 3', price: 100, status: 'idea')

      expect(event.total_spent).to eq(125)
    end
  end

  describe '#budget_remaining' do
    it 'shows remaining budget' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
      recipient = user.recipients.create(name: 'Mom')
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Gift', price: 100, status: 'purchased')

      expect(event.budget_remaining).to eq(400)
    end
  end

  describe '#budget_percentage' do
    it 'calculates percentage spent' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: 100)
      recipient = user.recipients.create(name: 'Mom')
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Gift', price: 25, status: 'purchased')

      expect(event.budget_percentage).to eq(25)
    end

    it 'returns 0 when budget is nil' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: nil)
      expect(event.budget_percentage).to eq(0)
    end
  end
end