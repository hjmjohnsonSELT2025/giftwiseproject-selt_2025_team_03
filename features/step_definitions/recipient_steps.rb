# frozen_string_literal: true

Given("I am on the Recipients page") do
  visit recipients_path   #change to actual route
end

Then("I should see a header {string}") do |header_text|
  expect(page).to have_content(header_text)
end

Then("I should see a button {string}") do |button_text|
  expect(page).to have_button(button_text).or have_link(button_text)
end

And("I should see the list of all recipients") do
  expect(page).to have_css(".recipient-card, .recipient-row, li")
end

Given("the user has no recipients added") do
  Recipient.delete_all
end

Then("I should see no recipients in the list") do
  expect(page).not_to have_css(".recipient-card, .recipient-row, li")
end

Given("a recipient exists") do
  @recipient = Recipient.create!(name: "Test User")
end

When("I click the button {string} for that recipient") do |button_text|
  within_recipient(@recipient.name) do
    click_link_or_button(button_text)
  end
end

Then("I should be taken to the recipient {string} page") do |page_type|
  case page_type
  when "View"
    expect(page).to have_current_path(recipient_path(@recipient))
  when "Edit"
    expect(page).to have_current_path(edit_recipient_path(@recipient))
  else
    raise "Unknown page type: #{page_type}"
  end
end

Then("I should remain on the {string} page") do |page_name|
  if page_name == "Recipients"
    expect(page).to have_current_path(recipients_path)
  else
    raise "Unknown page name: #{page_name}"
  end
end

Then("I should remain on the {string} page") do |page_name|
  if page_name == "Recipients"
    expect(page).to have_current_path(recipients_path)
  else
    raise "Unknown page name: #{page_name}"
  end
end

Then("I should see the new recipient form") do
  expect(page).to have_current_path(new_recipient_path)
end

#helper function that helps looking for a recipient
def within_recipient(name, &block)
  within(:xpath, "//*[contains(text(),'#{name}')]/ancestor::*[self::div or self::li][1]", &block)
end

Given("I am on the New Recipient form") do
  visit new_recipient_path
end

Then("I should see a field {string}") do |field_name|
  expect(page).to have_field(field_name)
end

When("I fill in {string} with {string}") do |field_name, value|
  fill_in field_name, with: value
end

When("I click the button {string}") do |button_text|
  click_button button_text
end

Then("I should see {string} in the recipient list") do |name|
  within("#recipient-list") do   #adjust selector to match our HTML
    expect(page).to have_content(name)
  end
end

Then("I should be taken to the {string} page") do |page_name|
  case page_name
  when "Recipients"
    expect(current_path).to eq recipients_path
  when "View"
    expect(current_path).to match(/recipients\/\d+/)
  when "Edit"
    expect(current_path).to match(/recipients\/\d+\/edit/)
  end
end

Then("I should see a validation error for {string}") do |field_name|
  expect(page).to have_content("#{field_name} can't be blank")
end
