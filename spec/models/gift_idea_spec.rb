require 'rails_helper'

RSpec.describe GiftIdea, type: :model do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User') }
  let(:event) { user.events.create(name: 'Christmas', date: Date.today) }
  let(:recipient) { user.recipients.create(name: 'Mom') }
  let(:event_recipient) { event.event_recipients.create(recipient: recipient) }

  it 'creates valid gift idea' do
    gift = event_recipient.gift_ideas.create(title: 'Necklace', price: 50)
    expect(gift).to be_valid
  end

  it 'requires a title' do
    gift = event_recipient.gift_ideas.new(price: 50)
    expect(gift).not_to be_valid
  end

  it 'allows nil price' do
    gift = event_recipient.gift_ideas.create(title: 'Surprise gift', price: nil)
    expect(gift).to be_valid
  end

  it 'rejects negative price' do
    gift = event_recipient.gift_ideas.new(title: 'Gift', price: -10)
    expect(gift).not_to be_valid
  end

  it 'defaults status to idea' do
    gift = event_recipient.gift_ideas.create(title: 'Gift')
    expect(gift.status).to eq('idea')
  end

  it 'accepts valid status values' do
    statuses = %w[idea backlogged purchased delivered wrapped liked]
    statuses.each do |status|
      gift = event_recipient.gift_ideas.create(title: 'Gift', status: status)
      expect(gift).to be_valid
    end
  end

  it 'rejects invalid status' do
    gift = event_recipient.gift_ideas.new(title: 'Gift', status: 'invalid_status')
    expect(gift).not_to be_valid
  end

  it 'belongs to event_recipient' do
    gift = event_recipient.gift_ideas.create(title: 'Gift')
    expect(gift.event_recipient).to eq(event_recipient)
  end
end