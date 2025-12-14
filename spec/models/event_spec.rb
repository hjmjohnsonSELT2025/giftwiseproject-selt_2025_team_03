require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user) do
    User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end
  let(:recipient) { user.recipients.create!(name: 'Mom') }

  describe 'Validations and Fundamentals' do
    it 'is valid with required attributes (name, date, user)' do
      event = user.events.create(name: 'Christmas', date: Date.today)
      expect(event).to be_valid
    end

    it 'requires a name and a date' do
      expect(user.events.new(date: Date.today)).not_to be_valid
      expect(user.events.new(name: 'Birthday')).not_to be_valid
    end

    it 'rejects negative budget' do
      event = user.events.new(name: 'Party', date: Date.today, budget: -50)
      expect(event).not_to be_valid
    end

    it 'handles events with very long names' do
      long_name = 'A' * 255
      event = user.events.create(name: long_name, date: Date.today)
      expect(event.name).to eq(long_name)
    end
  end

  describe 'Core Associations' do
    it 'belongs to a creator (user)' do
      event = user.events.create(name: 'Party', date: Date.today)
      expect(event.creator).to eq(user)
    end

    it 'sets the correct foreign key (user_id)' do
      event = user.events.create(name: 'Party', date: Date.today)
      expect(event.user_id).to eq(user.id)
    end

    it 'can have recipients through event_recipients' do
      event = user.events.create(name: 'Party', date: Date.today)
      event.recipients << recipient
      expect(event.recipients.count).to eq(1)
    end

    it 'has many invited_users through event_invitations' do
      invitee = User.create!(username: 'invitee', email: 'invitee@example.com', password: 'p', first_name: 'Invited', last_name: 'User')
      event = user.events.create(name: 'Party', date: Date.today)
      event.event_invitations.create!(inviter: user, invitee: invitee, status: 'pending')

      expect(event.invited_users).to include(invitee)
    end

    it 'destroys associated event_invitations when destroyed' do
      invitee = User.create!(username: 'invitee', email: 'invitee@example.com', password: 'p', first_name: 'Invited', last_name: 'User')
      event = user.events.create(name: 'Party', date: Date.today)
      event.event_invitations.create!(inviter: user, invitee: invitee, status: 'pending')

      expect {
        event.destroy
      }.to change(EventInvitation, :count).by(-1)
    end
  end

  describe 'Scopes and Helper Methods' do
    before do
      user.events.create(name: 'Past Event', date: 2.days.ago)
      user.events.create(name: 'Future Event', date: 2.days.from_now)
      user.events.create(name: 'Today Event', date: Date.today)
    end

    it 'finds upcoming events (future and today) using the upcoming scope' do
      upcoming = user.events.upcoming
      expect(upcoming.count).to eq(2)
      expect(upcoming.map(&:name)).to include('Future Event', 'Today Event')
    end

    it 'finds past events using the past scope' do
      expect(user.events.past.count).to eq(1)
      expect(user.events.past.map(&:name)).to include('Past Event')
    end

    it '#days_until returns positive for future events' do
      event = user.events.create(name: 'Future', date: 5.days.from_now.to_date)
      expect(event.days_until).to be_between(4, 6)
    end
  end

  describe 'Budget and Calculation Logic' do
    it '#total_spent calculates total only from purchased status gifts' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Purchased', price: 100, status: 'purchased', user: user)
      er.gift_ideas.create(title: 'Idea', price: 50, status: 'idea', user: user)

      event.reload
      expect(event.total_spent).to eq(100)
    end

    it 'correctly calculates budget_remaining after spending' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Gift', price: 100, status: 'purchased', user: user)

      event.reload
      expect(event.budget_remaining).to eq(400)
    end

    it 'correctly calculates budget_percentage spent' do
      event = user.events.create(name: 'Christmas', date: Date.today, budget: 500)
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Gift', price: 125, status: 'purchased', user: user)

      event.reload
      expect(event.budget_percentage).to eq(25)
    end

    it 'shows 100% spent when total spent equals the budget' do
      event = user.events.create(name: 'Full Spend', date: Date.today, budget: 200)
      er = event.event_recipients.create(recipient: recipient)
      er.gift_ideas.create(title: 'Gift', price: 200, status: 'purchased', user: user)

      event.reload
      expect(event.budget_percentage).to eq(100)
      expect(event.budget_remaining).to eq(0)
    end

    it 'sums spending across all recipients for total_spent and percentage' do
      event = user.events.create(name: 'Party', date: Date.today, budget: 500)
      recipient2 = user.recipients.create(name: 'Dad')

      er1 = event.event_recipients.create(recipient: recipient)
      er2 = event.event_recipients.create(recipient: recipient2)

      er1.gift_ideas.create(title: 'Gift 1', price: 50, status: 'purchased', user: user)
      er2.gift_ideas.create(title: 'Gift 2', price: 75, status: 'delivered', user: user)

      event.reload
      expect(event.total_spent).to eq(125)
      expect(event.budget_percentage).to eq(25)
    end

    it 'handles events with nil budget correctly for calculations' do
      event = user.events.create(name: 'Minimal Event', date: Date.today, budget: nil)
      expect(event.budget_percentage).to eq(0)
      expect(event.budget_remaining).to eq(0)
    end
  end
end