require 'rails_helper'

RSpec.describe Recipient, type: :model do
  let(:user) { User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User') }

  it 'creates valid recipient' do
    recipient = user.recipients.create(name: 'Mom')
    expect(recipient).to be_valid
  end

  it 'requires name' do
    recipient = user.recipients.new(name: nil)
    expect(recipient).not_to be_valid
  end

  it 'belongs to user' do
    recipient = user.recipients.create(name: 'Mom')
    expect(recipient.user).to eq(user)
  end

  it 'deletes when user deleted' do
    recipient = user.recipients.create(name: 'Mom')
    expect { user.destroy }.to change(Recipient, :count).by(-1)
  end
end