# frozen_string_literal: true
Given("I am logged in as a user") do
  @user = User.create!(
    username: "testuser",
    email: "test@example.com",
    password: "password",
    first_name: "Test",
    last_name: "User"
  )

  visit login_path
  fill_in "Username", with: "testuser"
  fill_in "Password", with: "password"
  click_button "Login"
end

Given("the following gift ideas exist:") do |table|
  table.hashes.each do |gift|
    recipient = Recipient.create!(
      name: "Test Recipient",
      user: @user
    )
    event = Event.create!(name: "Test Event", user: @user, date: Date.today)

    event_recipient = EventRecipient.create!(
      event: event,
      recipient: recipient
    )

    GiftIdea.create!(
      title: gift["title"],
      price: gift["price"],
      status: gift["status"],
      url: gift["url"],
      notes: gift["notes"],
      event_recipient: event_recipient,
      user: @user
    )
  end
end

Given("no gift ideas exist") do
  GiftIdea.delete_all
end

When("I visit the gift ideas page") do
  visit list_gifts_path
end

Given("I am on the add new gift page") do
  visit add_gifts_path
  @gift_idea = GiftIdea.new
end

When("I fill in gift idea field {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I select gift idea field {string} from {string}") do |option, field|
  select option, from: field
end

When("I press gift idea field {string}") do |button|
  click_button button
end

Then("I should see message {string}") do |text|
  expect(page).to have_content(text)
end
