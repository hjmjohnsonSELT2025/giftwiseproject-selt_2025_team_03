require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user) { User.create!(username: "user1", first_name: "User", last_name: "One", email: "user1@example.com", password: "password") }
  let(:friend) { User.create!(username: "user2", first_name: "User", last_name: "Two", email: "user2@example.com", password: "password") }

  describe "associations" do
    it "belongs to a user" do
      friendship = Friendship.new(user: user, friend: friend)
      expect(friendship.user).to eq(user)
    end

    it "belongs to a friend (User)" do
      friendship = Friendship.new(user: user, friend: friend)
      expect(friendship.friend).to eq(friend)
    end
  end

  describe "validations" do
    it "is valid with unique user_id and friend_id" do
      friendship = Friendship.new(user: user, friend: friend)
      expect(friendship.valid?).to be true
    end

    it "is invalid if the same friendship already exists" do
      Friendship.create!(user: user, friend: friend)
      duplicate = Friendship.new(user: user, friend: friend)
      expect(duplicate.valid?).to be false
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
  end
end
