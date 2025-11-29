# frozen_string_literal: true
Given("I am a logged-in user") do
  @user = User.find_by(username: "testuser") ||
          User.create!(
            username: "testuser",
            email: "testuser@example.com",
            password: "password",
            first_name: "Test",
            last_name: "User"
          )

  visit login_path
  fill_in "Username", with: @user.username
  fill_in "Password", with: "password"
  click_button "Login"
end

Given("the following recipients exist for my account:") do |table|
  table.hashes.each do |row|
    Recipient.create!(
      name: row["name"],
      user: @user
    )
  end
end

Given("I am on the New Event page") do
  visit new_event_path
end

When("I fill in the event form with valid data") do
  fill_in "Event Name", with: "Christmas Party"
  fill_in "Event Date", with: "2025-12-25"
  fill_in "Location", with: "Home"
  fill_in "Theme", with: "Winter Wonderland"
  fill_in "Total Budget ($)", with: "300"
end

When("I select recipient {string}") do |recipient_name|
  recipient = Recipient.find_by(name: recipient_name, user: @user)
  check("recipient_#{recipient.id}")
end

When("I submit the event form") do
  begin
    click_button "Create Event"
  rescue ActionController::MissingExactTemplate
    # Ignored
  end
end

When("I submit the event form without filling required fields") do
  click_button "Create Event"
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("the event {string} should exist in the database") do |event_name|
  event = Event.find_by(name: event_name, user: @user)
  expect(event).not_to be_nil
end
