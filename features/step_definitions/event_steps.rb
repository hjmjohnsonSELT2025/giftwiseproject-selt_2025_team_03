# frozen_string_literal: true
# Navigate to Events List page
Given("I am on the Events page") do
  visit events_path
end

Given("the following events exist:") do |table|
  table.hashes.each do |row|
    Event.create!(
      name: row["Name"],
      event_type: row["Type"],
      date: row["Date"],
      recipients: row["Recipients"]
    )
  end
end

# Check that an event appears in the list
Then("I should see {string} in the event list") do |event_name|
  within("#events-list") do
    expect(page).to have_content(event_name)
  end
end

# Check that each event has the specified buttons
Then("each event should have buttons {string}") do |buttons|
  buttons.split(", ").each do |button|
    within(".event-item") do
      expect(page).to have_button(button)
    end
  end
end

Given("an event exists with name {string}") do |name|
  Event.create!(
    name: name,
    event_type: "Birthday",        # default type; adjust as needed
    date: Date.today + 1.week,     # default date
    recipients: "Alice"            # default recipient
  )
end

# Click a specific action button for a specific event
When("I click {string} on the {string} event") do |action, event_name|
  within(find(".event-item", text: event_name)) do
    click_button(action)
  end
end

# Viewing an event’s details
Then("I should see the event name {string}") do |name|
  expect(page).to have_content(name)
end


Then("I should see the date {string}") do |date|
  expect(page).to have_content(date)
end

Then("I should see recipients {string}") do |recipients|
  expect(page).to have_content(recipients)
end

#clicking Add Event button navigates to New Event page
When("I click the button Add Event") do
  click_button("Add Event")
end

Then("I should not see {string} in the event list") do |event_name|
  within("#events-list") do
    expect(page).to have_no_content(event_name)
  end
end



Given("I am on the New Event form") do
  visit new_event_path #change event if neccessary
end

#these are for the dropdown, change if necessary

Then("I should see a dropdown {string}") do |dropdown|
  expect(page).to have_select(dropdown)
end

Then("the dropdown should contain:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_select(with_options: [option])
  end
end


When("I select {string} from the {string} dropdown") do |value, dropdown|
  select value, from: dropdown
end

#these are for the basic input fields

Then("I should see a field {string}") do |field|
  expect(page).to have_field(field)
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

#adding and removing the recipients
When("I add a recipient named {string}") do |name|
  #click Add Recipient button
  click_button "Add Recipient"

  #fills in the most recently added row
  within(all(".recipient-selector").last) do
    fill_in "Recipient Name", with: name
  end
end

Then("I should see {string} listed as a selected recipient") do |name|
  within("#recipient-list") do
    expect(page).to have_content(name)
  end
end

When("I remove the recipient named {string}") do |name|
  within("#recipient-list") do
    item = find(".recipient-item", text: name)
    item.find("button", text: "Remove").click
  end
end

Then("I should not see {string} listed as a selected recipient") do |name|
  within("#recipient-list") do
    expect(page).to have_no_content(name)
  end
end

#the text box that allows user to enter some extra info
Then("I should see a text box {string}") do |label|
  expect(page).to have_field(label)
end

#for the checkbox
Then("I should see a checkbox {string}") do |label|
  expect(page).to have_unchecked_field(label)
end

When("I check {string}") do |label|
  check(label)
end

#buttons
Then("I should see a button {string}") do |button|
  expect(page).to have_button(button)
end

When("I click the button {string}") do |button|
  click_button button
end

#page navigation validation
Then("I should be taken to the {string} page") do |page_name|
  expected_path =
    case page_name
    when "Events"
      events_path
    when "New Event"
      new_event_path
    else
      raise "Unknown page name: #{page_name}"
    end

  expect(current_path).to eq(expected_path)
end

#validation errors
Then("I should see a validation error for {string}") do |field|
  expect(page).to have_content("#{field} can't be blank")
end