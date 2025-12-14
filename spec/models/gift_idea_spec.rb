require 'rails_helper'

RSpec.describe GiftIdea, type: :model do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end
  let(:recipient) { user.recipients.create(name: 'Mom') }
  let(:event) { user.events.create(name: 'Christmas', date: Date.today) }
  let(:event_recipient) { event.event_recipients.create(recipient: recipient) }

  describe 'Fundamentals and General Validity' do
    it 'creates a valid gift idea with minimal required attributes' do
      gift = user.gift_ideas.create(
        event_recipient: event_recipient,
        title: 'Necklace',
        price: 50
      )
      expect(gift).to be_valid
    end

    it 'belongs to event_recipient' do
      gift = event_recipient.gift_ideas.create(title: 'Gift', user: user)
      expect(gift.event_recipient).to eq(event_recipient)
    end

    it 'requires an event_recipient' do
      gift = user.gift_ideas.new(title: 'General Gift Idea', price: 50)
      expect(gift).not_to be_valid
      expect(gift.errors[:event_recipient]).to be_present
    end
  end

  describe 'User Association and Dependencies' do
    it 'requires a user to be valid' do
      gift = GiftIdea.new(
        event_recipient: event_recipient,
        title: 'Gift',
        price: 50
      )

      expect(gift).not_to be_valid
      expect(gift.errors[:user]).to be_present
    end

    it 'belongs to the correct user' do
      gift = user.gift_ideas.create(
        event_recipient: event_recipient,
        title: 'Gift',
        price: 50
      )

      expect(gift.user).to eq(user)
    end

    it 'is destroyed when the associated user is destroyed' do
      gift = user.gift_ideas.create(
        event_recipient: event_recipient,
        title: 'Gift',
        price: 50
      )

      expect {
        user.destroy
      }.to change(GiftIdea, :count).by(-1)
    end
  end

  describe 'Title Validations' do
    it 'requires a title' do
      gift_nil = user.gift_ideas.new(event_recipient: event_recipient, price: 50)
      gift_empty = user.gift_ideas.new(event_recipient: event_recipient, title: '', price: 50)

      expect(gift_nil).not_to be_valid
      expect(gift_nil.errors[:title]).to be_present
      expect(gift_empty).not_to be_valid
    end

    it 'allows long titles and special characters' do
      long_title = 'A' * 100
      gift_long = user.gift_ideas.create(event_recipient: event_recipient, title: long_title, price: 50)
      gift_special = user.gift_ideas.create(event_recipient: event_recipient, title: "Mom's Special Gift! (2025)", price: 50)

      expect(gift_long).to be_valid
      expect(gift_special).to be_valid
    end
  end

  describe 'Price Validations and Edge Cases' do
    it 'allows nil price' do
      gift = user.gift_ideas.create(event_recipient: event_recipient, title: 'Surprise gift', price: nil)
      expect(gift).to be_valid
    end

    it 'allows zero price and decimal prices' do
      gift_zero = user.gift_ideas.create(event_recipient: event_recipient, title: 'Free Gift', price: 0)
      gift_decimal = user.gift_ideas.create(event_recipient: event_recipient, title: 'Deci Gift', price: 19.99)

      expect(gift_zero).to be_valid
      expect(gift_zero.price).to eq(0)
      expect(gift_decimal).to be_valid
      expect(gift_decimal.price).to eq(19.99)
    end

    it 'rejects negative price' do
      gift = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift', price: -10)
      expect(gift).not_to be_valid
    end

    it 'rejects non-numeric (string) prices' do
      gift = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift', price: 'expensive')
      expect(gift).not_to be_valid
    end
  end

  describe 'Status Validations and Default Behavior' do
    it 'defaults status to "idea" for new records' do
      gift_new = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift')
      gift_create = user.gift_ideas.create(event_recipient: event_recipient, title: 'Gift')

      expect(gift_new.status).to eq('idea')
      expect(gift_create.status).to eq('idea')
    end

    it 'accepts all valid status values' do
      %w[idea backlogged purchased delivered wrapped liked].each do |status|
        gift = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift', status: status)
        expect(gift).to be_valid, "Expected status '#{status}' to be valid"
      end
    end

    it 'rejects invalid status values (e.g., empty string or uppercase)' do
      gift_invalid = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift', status: 'invalid_status')
      gift_empty = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift', status: '')
      gift_uppercase = user.gift_ideas.new(event_recipient: event_recipient, title: 'Gift', status: 'PURCHASED')

      expect(gift_invalid).not_to be_valid
      expect(gift_empty).not_to be_valid
      expect(gift_uppercase).not_to be_valid
    end

    it 'does not override explicitly set status' do
      gift = user.gift_ideas.create(event_recipient: event_recipient, title: 'Gift', status: 'purchased')
      expect(gift.status).to eq('purchased')
    end
  end

  describe 'Optional Fields (URL and Notes)' do
    it 'allows url and notes to be nil' do
      gift = user.gift_ideas.create(event_recipient: event_recipient, title: 'Gift', url: nil, notes: nil)
      expect(gift).to be_valid
    end

    it 'stores url and long notes correctly' do
      url = 'https://example.com/product'
      notes = 'A' * 500
      gift = user.gift_ideas.create(event_recipient: event_recipient, title: 'Gift', url: url, notes: notes)

      expect(gift.url).to eq(url)
      expect(gift.notes).to eq(notes)
    end
  end
end