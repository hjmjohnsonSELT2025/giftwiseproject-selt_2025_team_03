require "rails_helper"

RSpec.describe EventInvitation, type: :model do
  let(:inviter) do
    User.create!(
      email: "inviter@example.com",
      password: "password",
      username: "inviter_user",
      first_name: "Inviter",
      last_name: "User"
    )
  end

  let(:invitee) do
    User.create!(
      email: "invitee@example.com",
      password: "password",
      username: "invitee_user",
      first_name: "Invitee",
      last_name: "User"
    )
  end

  let(:event) do
    Event.create!(
      name: "Test Event",
      user_id: inviter.id,
      date: Date.today + 1.week
    )
  end

  subject do
    described_class.new(
      event: event,
      inviter: inviter,
      invitee: invitee,
      status: "pending"
    )
  end

  describe "enums" do
    it "defines statuses" do
      expect(described_class.statuses.keys).to match_array(%w[pending accepted declined])
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without an event" do
      subject.event = nil
      expect(subject).to_not be_valid
    end

    it "is invalid without an inviter" do
      subject.inviter = nil
      expect(subject).to_not be_valid
    end

    it "is invalid without an invitee" do
      subject.invitee = nil
      expect(subject).to_not be_valid
    end

    it "enforces uniqueness of event_id scoped to invitee_id" do
      subject.save!
      duplicate = described_class.new(event: event, inviter: inviter, invitee: invitee)
      expect(duplicate).to_not be_valid
      expect(duplicate.errors[:event_id]).to include("has already been taken")
    end
  end
end
