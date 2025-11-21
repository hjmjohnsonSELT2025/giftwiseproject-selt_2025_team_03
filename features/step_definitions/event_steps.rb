# frozen_string_literal: true

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