<<<<<<< HEAD
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'creates a valid user' do
    user = User.create(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    )
    expect(user).to be_valid
  end

  it 'rejects user without username' do
    user = User.new(email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(user).not_to be_valid
  end

  it 'rejects user without email' do
    user = User.new(username: 'testuser', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(user).not_to be_valid
  end

  it 'rejects user without first name' do
    user = User.new(username: 'testuser', email: 'test@example.com', password: 'password123', last_name: 'User')
    expect(user).not_to be_valid
  end

  it 'rejects user without last name' do
    user = User.new(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test')
    expect(user).not_to be_valid
  end

  it 'rejects duplicate username' do
    User.create(username: 'testuser', email: 'test1@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    duplicate = User.new(username: 'testuser', email: 'test2@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(duplicate).not_to be_valid
  end

  it 'rejects duplicate email' do
    User.create(username: 'user1', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    duplicate = User.new(username: 'user2', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(duplicate).not_to be_valid
  end

  it 'converts email to lowercase' do
    user = User.create(username: 'testuser', email: 'TEST@EXAMPLE.COM', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(user.email).to eq('test@example.com')
  end

  it 'authenticates with correct password' do
    user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(user.authenticate('password123')).to eq(user)
  end

  it 'fails authentication with wrong password' do
    user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    expect(user.authenticate('wrong')).to be_falsey
  end

  it 'has many recipients' do
    user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    user.recipients.create(name: 'Mom')
    user.recipients.create(name: 'Dad')
    expect(user.recipients.count).to eq(2)
  end

  it 'has many events' do
    user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    user.events.create(name: 'Christmas', date: Date.today)
    user.events.create(name: 'Birthday', date: Date.today)
    expect(user.events.count).to eq(2)
  end

  it 'deletes associated recipients when deleted' do
    user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    user.recipients.create(name: 'Mom')
    expect { user.destroy }.to change(Recipient, :count).by(-1)
  end

  it 'deletes associated events when deleted' do
    user = User.create(username: 'testuser', email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User')
    user.events.create(name: 'Christmas', date: Date.today)
    expect { user.destroy }.to change(Event, :count).by(-1)
  end
=======
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      first_name: 'Test',
      last_name: 'User'
    }
  end
  let(:user) { User.create(valid_attributes) }

  describe 'Core Validations and Fundamentals' do
    it 'creates a valid user with all required attributes' do
      expect(user).to be_valid
    end

    it 'requires username, email, first name, and last name' do
      required_fields = [:username, :email, :first_name, :last_name]

      required_fields.each do |field|
        user = User.new(valid_attributes.except(field))
        expect(user).not_to be_valid
        expect(user.errors[field]).to be_present
      end
    end

    it 'requires a password on create' do
      user = User.new(valid_attributes.except(:password))
      expect(user).not_to be_valid
      expect(user.errors[:password_digest] || user.errors[:password]).to be_present
    end
  end

  describe 'Uniqueness and Data Processing' do
    before { User.create(valid_attributes) }

    it 'rejects duplicate username and email' do
      duplicate_username = User.new(valid_attributes.merge(email: 'different@example.com'))
      expect(duplicate_username).not_to be_valid
      expect(duplicate_username.errors[:username]).to be_present
      duplicate_email = User.new(valid_attributes.merge(username: 'differentuser'))
      expect(duplicate_email).not_to be_valid
      expect(duplicate_email.errors[:email]).to be_present
    end

    it 'converts email to lowercase before saving (case insensitivity)' do
      user = User.create(valid_attributes.merge(username: 'newuser', email: 'TeSt@ExAmPlE.CoM'))
      expect(user.email).to eq('test@example.com')
    end

    it 'allows same username and email for different users after original is deleted' do
      User.find_by(username: 'testuser').destroy
      new_user = User.new(valid_attributes)
      expect(new_user).to be_valid
    end
  end

  describe 'Password Authentication' do
    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'fails authentication with wrong, nil, or empty passwords' do
      expect(user.authenticate('wrongpassword')).to be_falsey
      expect(user.authenticate(nil)).to be_falsey
      expect(user.authenticate('')).to be_falsey
    end

    it 'stores password securely (not in plain text)' do
      expect(user.password_digest).not_to eq('password123')
      expect(user.password_digest).to be_present
    end
  end

  describe 'Associations and Dependent Destroy' do
    let!(:recipient) { user.recipients.create(name: 'Mom') }
    let!(:event) { user.events.create(name: 'Christmas', date: Date.today) }
    let!(:event_recipient) { event.event_recipients.create(recipient: recipient) }
    let!(:gift_idea) { user.gift_ideas.create(event_recipient: event_recipient, title: 'Gift', price: 50) }

    let(:other_user) { User.create(valid_attributes.merge(username: 'other', email: 'other@example.com')) }
    let!(:sent_invitation) { EventInvitation.create(event: event, inviter: user, invitee: other_user) }

    let!(:other_event) { other_user.events.create(name: 'Birthday', date: Date.today) }
    let!(:received_invitation) { EventInvitation.create(event: other_event, inviter: other_user, invitee: user) }

    it 'has correct primary associations (recipients, events, gift_ideas)' do
      expect(user.recipients).to include(recipient)
      expect(user.events).to include(event)
      expect(user.gift_ideas).to include(gift_idea)
    end

    it 'handles event invitation associations (sent, received, and invited events)' do
      # Sent invitations
      expect(user.sent_event_invitations).to include(sent_invitation)
      expect(user.sent_event_invitations.count).to eq(1)

      # Received invitations
      expect(user.received_event_invitations).to include(received_invitation)
      expect(user.received_event_invitations.count).to eq(1)

      # Invited events
      expect(user.invited_events).to include(other_event)
      expect(user.invited_events.count).to eq(1)
    end

    it 'deletes all associated data (Recipients, Events, GiftIdeas, Invitations) when user is destroyed' do
      # Pre-check counts
      expect(Recipient.count).to eq(1)
      expect(Event.count).to eq(2) # user's event + other_user's event
      expect(GiftIdea.count).to eq(1)
      expect(EventInvitation.count).to eq(2)

      expect {
        user.destroy
      }.to change(Recipient, :count).by(-1)
                                    .and change(Event, :count).by(-1) # Only the user's event is deleted
                                                              .and change(GiftIdea, :count).by(-1)
                                                                                           .and change { EventInvitation.where(inviter_id: user.id).count }.from(1).to(0) # Sent invitations
                                                                                                                                                           .and change { EventInvitation.where(invitee_id: user.id).count }.from(1).to(0) # Received invitations
    end
  end

  describe 'Optional Fields' do
    it 'allows birthday to be nil and stores it as a date' do
      birthday = Date.new(1990, 5, 15)
      user_with_bday = User.create(valid_attributes.merge(birthday: birthday))
      user_without_bday = User.create(valid_attributes.merge(username: 'no_bday', email: 'no_bday@ex.com', birthday: nil))

      expect(user_with_bday.birthday).to eq(birthday)
      expect(user_without_bday.birthday).to be_nil
    end

    it 'allows public_profile to be nil and stores it as boolean' do
      user_public = User.create(valid_attributes.merge(public_profile: true))
      user_default = User.create(valid_attributes.merge(username: 'default', email: 'default@ex.com'))

      expect(user_public.public_profile).to be true
      expect(user_default.public_profile).to be_nil
    end

    it 'stores likes and dislikes as strings' do
      user = User.create(valid_attributes.merge(likes: 'reading, hiking', dislikes: 'spiders'))

      expect(user.likes).to eq('reading, hiking')
      expect(user.dislikes).to eq('spiders')
    end
  end
>>>>>>> origin/blake-app
end