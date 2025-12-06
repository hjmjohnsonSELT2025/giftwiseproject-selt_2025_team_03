# frozen_string_literal: true

# Background steps
Given("I am logged in as a user") do
  @user = User.create!(
    username: "testuser",
    email: "test@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Test",
    last_name: "User",
    birthday: Date.new(1990, 1, 1)
  )

  # Log in the user
  visit login_path
  fill_in "username", with: "testuser"
  fill_in "password", with: "password123"
  click_button "Login"
end

# Given steps
Given("the following events exist:") do |table|
  table.hashes.each do |row|
    event = Event.create!(
      user: @user,
      name: row['Name'],
      date: Date.parse(row['Date']),
      location: row['Location'] || "Unknown",
      budget: row['Budget']&.to_f || 0,
      theme: row['Theme']
    )

    # Add recipients if specified
    if row['Recipients']
      row['Recipients'].split(',').each do |recipient_name|
        recipient_name = recipient_name.strip
        recipient = Recipient.find_or_create_by!(
          user: @user,
          name: recipient_name
        )
        EventRecipient.create!(event: event, recipient: recipient)
      end
    end
  end
end

Given("the user has no events added") do
  Event.where(user_id: @user.id).delete_all
end

Given("an event exists with name {string}") do |event_name|
  @event = Event.create!(
    user: @user,
    name: event_name,
    date: Date.new(2025, 5, 10),
    budget: 200,
    location: "Restaurant"
  )
end

Given("another user exists with events") do
  @other_user = User.create!(
    username: "otheruser",
    email: "other@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: "Other",
    last_name: "User",
    birthday: Date.new(1985, 5, 15)
  )

  @other_event = Event.create!(
    user: @other_user,
    name: "Other User's Event",
    date: Date.new(2025, 7, 1),
    budget: 500,
    location: "Other Location"
  )
end

Given("I am on the Events page") do
  visit events_path
end

# When steps
When("I click the button {string}") do |button_text|
  click_link_or_button(button_text)
end

When("I click {string} on the {string} event") do |action, event_name|
  @event = Event.find_by(name: event_name, user_id: @user.id)
  within_event(event_name) do
    case action
    when "View"
      click_link_or_button("View")
    when "Edit"
      click_link_or_button("Edit")
    when "Delete"
      click_link_or_button("Delete")
    else
      click_link_or_button(action)
    end
  end
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I search for {string}") do |query|
  fill_in "search-events", with: query
  # Wait for AJAX to complete
  sleep 0.5
end

# Then steps
Then("I should see {string} in the event list") do |event_name|
  expect(page).to have_content(event_name)
end

Then("I should not see {string} in the event list") do |event_name|
  expect(page).not_to have_content(event_name)
end

Then("each event should have buttons {string}") do |button_list|
  buttons = button_list.split(', ')
  buttons.each do |button|
    expect(page).to have_link(button).or have_button(button)
  end
end

Then("I should see no events in the list") do
  expect(page).not_to have_css(".event-container")
end

Then("I should see a message {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should be taken to the {string} page") do |page_name|
  case page_name
  when "New Event"
    expect(page).to have_current_path(new_event_path)
  when "Edit Event"
    expect(page).to have_current_path(edit_event_path(@event))
  else
    raise "Unknown page: #{page_name}"
  end
end

Then("I should see the event details page") do
  expect(page).to have_current_path(event_path(@event))
end

Then("I should see the event name {string}") do |event_name|
  expect(page).to have_content(event_name)
end

Then("I should see the date {string}") do |date_string|
  expect(page).to have_content(date_string)
end

Then("I should be taken to the edit event page") do
  expect(page).to have_current_path(edit_event_path(@event))
end

Then("I should be redirected to the Events page") do
  expect(page).to have_current_path(events_path)
end

Then("I should not see the other user's events") do
  expect(page).not_to have_content(@other_event.name)
end

# Helper function to find event container
def within_event(name, &block)
  within(:xpath, "//*[contains(text(),'#{name}')]/ancestor::div[@class='event-container'][1]", &block)
end