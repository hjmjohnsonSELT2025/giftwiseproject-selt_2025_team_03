# frozen_string_literal: true
Given("I am on the dashboard") do
  #create test user
  @user = User.find_by(username: "testuser") ||
          User.create!(
            username: "testuser",
            email: "testuser@example.com", # <--- required
            password: "password",
            first_name: "Test",
            last_name: "User"
          )

  #log in
  visit login_path
  fill_in "Username", with: @user.username
  fill_in "Password", with: "password"
  click_button "Login"

  #go to dashboard
  visit dashboard_path
end

Then("I should see the buttons: {string}") do |buttons|
  buttons.split(",").map(&:strip).each do |button|
    expect(page).to have_css(".nav-item span", text: button)
  end
end

Then("I should see a list of recent activity") do
  expect(page).to have_css(".activity-card")
  #checks for recent activity
  expect(page).to have_text("Recent Activity")
end

When("I click the dashboard button {string}") do |button_text|
  if button_text == "Profile"
    find('#profile-link').click          # open dropdown
    find('a', text: 'Profile Settings').click
  elsif button_text == "Logout"
    find('#profile-link').click          # open dropdown
    find('a', text: 'Logout').click
  else
    click_on(button_text)                # everything else works normally
  end
end

Then("I should see the {string} page") do |text|
  expect(page).to have_text(text)
end