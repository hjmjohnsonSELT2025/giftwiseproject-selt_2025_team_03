require 'rails_helper'

RSpec.describe Recipient, type: :model do
  let(:user) do
    User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
  end
  let(:other_user) do
    User.create(
      username: 'otheruser',
      email: 'other@example.com',
      password: 'password123',
      first_name: 'Other',
      last_name: 'User'
    )
  end

  describe 'Core Validations and Fundamentals' do
    it 'creates a valid recipient' do
      recipient = user.recipients.create(name: 'Mom')
      expect(recipient).to be_valid
    end

    it 'requires a name' do
      recipient = user.recipients.new(name: nil)
      expect(recipient).not_to be_valid
      expect(recipient.errors[:name]).to be_present
    end

    it 'allows names with special characters and long length' do
      recipient1 = user.recipients.create(name: "O'Brien-Smith Jr.")
      recipient2 = user.recipients.create(name: 'A' * 100)

      expect(recipient1).to be_valid
      expect(recipient2).to be_valid
    end

    it 'preserves leading/trailing whitespace in name (if not trimmed by a callback)' do
      recipient = user.recipients.create(name: "  Mom  ")
      expect(recipient.name).to eq("  Mom  ")
    end
  end

  describe 'Uniqueness Validation (scoped to user)' do
    before { user.recipients.create(name: 'Mom') }

    it 'prevents duplicate names for the same user' do
      duplicate = user.recipients.new(name: 'Mom')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name].first).to eq('is already in your recipient list.')
    end

    it 'is case insensitive for uniqueness' do
      duplicate_lower = user.recipients.new(name: 'mom')
      duplicate_upper = user.recipients.new(name: 'MOM')

      expect(duplicate_lower).not_to be_valid
      expect(duplicate_upper).not_to be_valid
    end

    it 'allows the same name for different users' do
      other_recipient = other_user.recipients.new(name: 'Mom')

      expect(other_recipient).to be_valid
    end

    it 'allows different names for same user' do
      new_recipient = user.recipients.new(name: 'Dad')

      expect(new_recipient).to be_valid
    end
  end

  describe 'Associations' do
    it 'belongs to user (as creator)' do
      recipient = user.recipients.create(name: 'Mom')
      expect(recipient.user).to eq(user)
      expect(recipient.creator).to eq(user)
      expect(recipient.user_id).to eq(user.id)
    end

    it 'deletes associated recipient when user is deleted' do
      user.recipients.create(name: 'Mom')
      expect { user.destroy }.to change(Recipient, :count).by(-1)
    end

    it 'has many events through event_recipients' do
      recipient = user.recipients.create(name: 'Mom')
      event1 = user.events.create(name: 'Christmas', date: Date.today)
      event2 = user.events.create(name: 'Birthday', date: Date.today)

      recipient.events << event1
      recipient.events << event2

      expect(recipient.events.count).to eq(2)
      expect(recipient.events).to include(event1, event2)
    end

    it 'destroys event_recipients when recipient is deleted' do
      recipient = user.recipients.create(name: 'Mom')
      event = user.events.create(name: 'Christmas', date: Date.today)
      recipient.events << event

      expect {
        recipient.destroy
      }.to change(EventRecipient, :count).by(-1)
    end

    it 'has many gift_ideas through event_recipients and destroys them when recipient is deleted' do
      recipient = user.recipients.create(name: 'Mom')
      event = user.events.create(name: 'Christmas', date: Date.today)
      er = event.event_recipients.create(recipient: recipient)
      gift = user.gift_ideas.create(event_recipient: er, title: 'Gift', price: 50)

      expect(recipient.gift_ideas).to include(gift)

      expect {
        recipient.destroy
      }.to change(GiftIdea, :count).by(-1)
    end
  end

  describe 'Optional Fields (Data Storage)' do
    it 'stores long text fields for likes and dislikes' do
      long_text = 'A' * 500
      recipient = user.recipients.create(
        name: 'Mom',
        likes: long_text,
        dislikes: long_text
      )

      expect(recipient.likes).to eq(long_text)
      expect(recipient.dislikes).to eq(long_text)
    end

    it 'allows nil values for all optional fields' do
      recipient = user.recipients.new(
        name: 'Test',
        likes: nil,
        dislikes: nil,
        relationship: nil,
        relationship_other: nil,
        birthday: nil,
        visible: nil
      )
      expect(recipient).to be_valid
    end

    it 'stores birthday as date' do
      birthday = Date.new(1970, 5, 15)
      recipient = user.recipients.create(name: 'Mom', birthday: birthday)

      expect(recipient.birthday).to eq(birthday)
    end

    it 'stores relationship and relationship_other' do
      recipient = user.recipients.create(
        name: 'Neighbor',
        relationship: 'Other',
        relationship_other: 'Close Neighbor'
      )

      expect(recipient.relationship).to eq('Other')
      expect(recipient.relationship_other).to eq('Close Neighbor')
    end
  end

  describe 'Visibility Field and Scopes' do
    before do
      user.recipients.create(name: 'Public Mom', visible: true)
      user.recipients.create(name: 'Private Dad', visible: false)
      user.recipients.create(name: 'Nil Visibility', visible: nil)
    end

    it 'defaults visible to nil when not specified' do
      recipient = user.recipients.create(name: 'New Recipient')
      expect(recipient.visible).to be_nil
    end

    it 'has publicly_visible scope (returns only true values)' do
      visible = user.recipients.publicly_visible

      expect(visible.count).to eq(1)
      expect(visible.first.name).to eq('Public Mom')
      visible.each { |r| expect(r.visible).to be true }
    end

    it 'has private_only scope (includes false and nil values)' do
      private_recipients = user.recipients.private_only

      expect(private_recipients.count).to eq(2)
      expect(private_recipients.pluck(:name)).to contain_exactly('Private Dad', 'Nil Visibility')
      private_recipients.each { |r| expect(r.visible).to be_falsey }
    end
  end
end