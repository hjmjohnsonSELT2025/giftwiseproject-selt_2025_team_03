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

