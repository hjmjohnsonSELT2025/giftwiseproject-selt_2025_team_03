# frozen_string_literal: true

Given("I am on the main page") do
  vist root_path
end

Then("I should see the buttons: {string}") do |button|
  buttons.each do |button|
    expect(page).to have_button(button)
  end
end

Then("I should see a list of recent activity") do
  expect(page).to have_css(".recent-activity")
end

When("I click the button {string}") do |button|
  click_button(button)
end

Then("I should see the {string} page") do |text|
  expect(page).to have_text(text)
end