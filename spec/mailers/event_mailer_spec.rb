require "rails_helper"

RSpec.describe EventMailer, type: :mailer do
  let(:user) do
    User.create!(
      first_name: "Nico",
      last_name: "Harrison",
      username: "nico123",
      email: "nico@example.com",
      password: "password"
    )
  end

  # Create a sample event
  let(:event) do
    Event.create!(
      name: "Birthday Party",
      date: Date.today + 7.days,
      user: user
    )
  end

  # Create a sample recipient
  let(:recipient) do
    Recipient.create!(
      name: "Bob",
      user: user
    )
  end

  describe "#upcoming_event_week" do
    let(:mail) { EventMailer.upcoming_event_week(event) }

    it "renders the headers correctly" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@example.com"])
      expect(mail.subject).to eq("Reminder: #{event.name} is 1 week away!!")
    end

    it "renders the body with the event and user info" do
      body = mail.body.encoded
      expect(body).to match("Hi #{user.first_name}")
      expect(body).to match("Your event <strong>#{event.name}</strong> is 1 week away!")
      expect(body).to match(event.date.strftime("%B %d, %Y"))
    end
  end

  describe "#upcoming_event_day" do
    let(:mail) { EventMailer.upcoming_event_day(event) }

    it "renders the headers correctly" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@example.com"])
      expect(mail.subject).to eq("HOLY SMOKES! #{event.name} is tommorrow!!")
    end

    it "renders the body with the event and user info" do
      body = mail.body.encoded
      expect(body).to match("#{user.first_name} GET READY!⏰")
      expect(body).to match("Your event <strong>#{event.name}</strong> is tomorrow!")
      expect(body).to match("Make sure your gift is ready!")
    end
  end

  describe "#weekly_summary" do
    before do
      # ensure the event and recipient are within last week
      event.update!(created_at: 2.days.ago)
      recipient.update!(created_at: 2.days.ago)
    end

    let(:mail) { EventMailer.weekly_summary(user) }

    it "renders the headers correctly" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@example.com"])
      expect(mail.subject).to eq("Your Weekly GiftWise Summary")
    end

    it "renders the body including new events and recipients" do
      body = mail.body.encoded
      expect(body).to match("Your Weekly GiftWise Summary 📊")
      expect(body).to match("New Events")
      expect(body).to match(event.name)
      expect(body).to match("New Recipients")
      expect(body).to match(recipient.name)
    end
  end
end
