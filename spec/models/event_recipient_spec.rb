require 'rails_helper'

RSpec.describe EventRecipient, type: :model do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User') }
  let(:event) { user.events.create(name: 'Christmas', date: Date.today) }
  let(:recipient) { user.recipients.create(name: 'Mom') }

  it 'creates valid event_recipient' do
    er = event.event_recipients.create(recipient: recipient)
    expect(er).to be_valid
  end

  it 'belongs to event' do
    er = event.event_recipients.create(recipient: recipient)
    expect(er.event).to eq(event)
  end

  it 'belongs to recipient' do
    er = event.event_recipients.create(recipient: recipient)
    expect(er.recipient).to eq(recipient)
  end

  it 'prevents duplicate event-recipient pairs' do
    event.event_recipients.create(recipient: recipient)
    duplicate = event.event_recipients.new(recipient: recipient)
    expect(duplicate).not_to be_valid
  end

  it 'allows same recipient in different events' do
    event2 = user.events.create(name: 'Birthday', date: Date.today)
    event.event_recipients.create(recipient: recipient)
    er2 = event2.event_recipients.create(recipient: recipient)
    expect(er2).to be_valid
  end

  it 'has many gift ideas' do
    er = event.event_recipients.create(recipient: recipient)
    er.gift_ideas.create(title: 'Gift 1')
    er.gift_ideas.create(title: 'Gift 2')
    expect(er.gift_ideas.count).to eq(2)
  end
end