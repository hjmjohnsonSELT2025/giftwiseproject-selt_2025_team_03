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
    user = User.new(email: 'test@example.com', password: 'password123')
    expect(user).not_to be_valid
  end

  it 'rejects user without email' do
    user = User.new(username: 'testuser', password: 'password123')
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
end