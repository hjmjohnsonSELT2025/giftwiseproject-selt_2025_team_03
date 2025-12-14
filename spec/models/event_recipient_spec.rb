require 'rails_helper'

RSpec.describe EventRecipient, type: :model do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end
  let(:event) { user.events.create(name: 'Christmas', date: Date.today) }
  let(:recipient) { user.recipients.create(name: 'Mom') }

  describe 'Core Validations and Associations' do
    it 'creates a valid record and belongs to event and recipient' do
      er = event.event_recipients.create(recipient: recipient)
      expect(er).to be_valid
      expect(er.event).to eq(event)
      expect(er.recipient).to eq(recipient)
    end

    it 'requires both an event and a recipient' do
      er_no_event = EventRecipient.new(recipient: recipient)
      er_no_recipient = EventRecipient.new(event: event)
      expect(er_no_event).not_to be_valid
      expect(er_no_event.errors[:event]).to be_present
      expect(er_no_recipient).not_to be_valid
      expect(er_no_recipient.errors[:recipient]).to be_present
    end
  end

  describe 'Uniqueness and Relationships' do
    it 'prevents duplicate event-recipient pairs' do
      # Create the first event_recipient
      event.event_recipients.create(recipient: recipient)
      # Try to create duplicate
      duplicate = event.event_recipients.new(recipient: recipient)
      expect(duplicate).not_to be_valid
      # The error could be on :event, :recipient, :event_id, or :recipient_id depending on model setup
      expect(duplicate.errors.full_messages).to include(/already been taken|has already been taken/)
    end

    it 'allows same recipient in a different event' do
      event.event_recipients.create(recipient: recipient)
      event2 = user.events.create(name: 'Birthday', date: Date.today)
      er2 = event2.event_recipients.new(recipient: recipient)
      expect(er2).to be_valid
    end

    it 'allows same event with a different recipient' do
      event.event_recipients.create(recipient: recipient)
      recipient2 = user.recipients.create(name: 'Dad')
      er2 = event.event_recipients.new(recipient: recipient2)
      expect(er2).to be_valid
    end

    it 'provides bidirectional access to associated event and recipient' do
      # Actually create the event_recipient first
      event.event_recipients.create(recipient: recipient)
      # Checks the EventRecipient model implicitly by testing the `has_many through` associations
      expect(event.recipients).to include(recipient)
      expect(recipient.events).to include(event)
    end
  end

  describe 'Gift Ideas and Optional Fields' do
    it 'has many gift ideas and returns the collection' do
      er = event.event_recipients.create(recipient: recipient)
      user.gift_ideas.create(event_recipient: er, title: 'Gift 1', price: 50)
      user.gift_ideas.create(event_recipient: er, title: 'Gift 2', price: 30)

      expect(er.gift_ideas.count).to eq(2)
    end

    it 'handles budget (nil, zero, and decimal values)' do
      # Create separate recipients to avoid uniqueness constraint violations
      recipient1 = user.recipients.create(name: 'Recipient1')
      recipient2 = user.recipients.create(name: 'Recipient2')

      # Test nil/decimal
      er_valid = event.event_recipients.create(recipient: recipient1, budget: 150.50)
      expect(er_valid).to be_valid
      expect(er_valid.budget.to_f).to eq(150.50)

      # Test zero
      er_zero = event.event_recipients.create(recipient: recipient2, budget: 0)
      expect(er_zero).to be_valid
      expect(er_zero.budget.to_f).to eq(0.0)
    end

    it 'rejects negative budget' do
      recipient_negative = user.recipients.create(name: 'RecipientNegative')
      er_negative = event.event_recipients.new(recipient: recipient_negative, budget: -50)
      expect(er_negative).not_to be_valid
      expect(er_negative.errors[:budget]).to be_present
    end

    it 'allows and stores long notes text' do
      er = event.event_recipients.create(recipient: recipient, notes: 'A' * 500)
      expect(er.notes).to eq('A' * 500)
    end
  end

  describe 'Dependent Destroy Checks' do
    it 'destroys associated gift ideas when EventRecipient is deleted' do
      er = event.event_recipients.create(recipient: recipient)
      user.gift_ideas.create(event_recipient: er, title: 'Gift', price: 50)

      expect {
        er.destroy
      }.to change(GiftIdea, :count).by(-1)
    end

    it 'is destroyed when parent Event is deleted (EventRecipient must be dependent on Event)' do
      er = event.event_recipients.create(recipient: recipient)
      user.gift_ideas.create(event_recipient: er, title: 'Gift', price: 50)

      expect {
        event.destroy
      }.to change(EventRecipient, :count).by(-1)
                                         .and change(GiftIdea, :count).by(-1) # Ensures GiftIdea is cleaned up via ER deletion
    end

    it 'is destroyed when parent Recipient is deleted (EventRecipient must be dependent on Recipient)' do
      er = event.event_recipients.create(recipient: recipient)
      user.gift_ideas.create(event_recipient: er, title: 'Gift', price: 50)

      expect {
        recipient.destroy
      }.to change(EventRecipient, :count).by(-1)
                                         .and change(GiftIdea, :count).by(-1) # Ensures GiftIdea is cleaned up via ER deletion
    end
  end
end