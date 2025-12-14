# spec/mailers/user_mailer_spec.rb
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  #create a user with fields
  let(:user) do
    User.create!(
      first_name: "Pokio",
      last_name:  "Pokio",
      username:   "pokio123",
      email:      "pokio@example.com",
      password:   "password"
    )
  end

  describe "#welcome_email" do
    let(:mail) { UserMailer.welcome_email(user) }

    it "renders the headers correctly" do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["notifications@example.com"])
      expect(mail.subject).to eq("Welcome to GIFTWISE!")
    end

    it "renders the body including the user's first name and welcome text" do
      body = mail.body.encoded
      expect(body).to match("Welcome, #{user.first_name}")
      expect(body).to match("Thanks for joining <strong>GiftWise</strong>")
      expect(body).to match("You're all set to start organizing your recipients")
      expect(body).to match("Jump in anytime and discover thoughtful ideas")
    end
  end
end
