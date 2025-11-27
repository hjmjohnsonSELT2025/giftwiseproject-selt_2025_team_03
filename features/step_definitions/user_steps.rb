# user login steps
Given("a user exists with username {string} and password {string}") do |username, password|
  User.create!(
    first_name: "Test",
    last_name: "User",
    email: "#{username}@example.com",
    username: "testuser",
    password: password
  )
end

Given('I am on the login page') do
  visit login_path
end

Then("I should see the field {string}") do |field|
  expect(page).to have_field(field)
end


Then("I should see the link {string}") do |link|
  expect(page).to have_link(link)
end

When("I click the link {string}") do |link|
  click_link link
end

Then("I should be on the registration page") do
  expect(current_path).to eq(new_user_path)
end

When("I fill in login field with {string} with {string}") do |label, value|
  fill_in label, with: value
end

When("I click the login field button {string}") do |button|
  click_button button
end

Then("I should be on the dashboard page") do
  expect(current_path).to eq(dashboard_path)
end

Then("I should be on the login page") do
  expect(current_path).to eq(login_path)
end

# user registration steps

Given("I am on the registration page") do
  visit new_user_path
end

Then("I should see the registration form fields") do
  expect(page).to have_field("First Name")
  expect(page).to have_field("Last Name")
  expect(page).to have_field("Email")
  expect(page).to have_field("Username")
  expect(page).to have_field("Password")
  expect(page).to have_field("Confirm password")
  expect(page).to have_field("Birthday")
end

Then("I should see the button {string}") do |text|
  expect(page).to have_button(text)
end

Then("I should see the login link") do
  expect(page).to have_link("Login")
end

When("I click the user registration button {string}") do |button|
  click_button(button)
end


# valid form submitted
When("I fill in the registration form with valid details") do
  fill_in "First Name", with: "John"
  fill_in "Last Name", with: "Smith"
  fill_in "Email", with: "jsmith@example.com"
  fill_in "Username", with: "jsmith"
  fill_in "Password", with: "Password1!"
  fill_in "Confirm password", with: "Password1!"
  fill_in "Birthday", with: "2000-01-01"
end


#invalid password
When("I enter an invalid password") do
  fill_in "First Name", with: "John"
  fill_in "Last Name", with: "Smith"
  fill_in "Email", with: "jsmith@example.com"
  fill_in "Username", with: "jsmith"
  fill_in "Password", with: "123"
  fill_in "Confirm password", with: "123"
end


#invalid email
When("I enter an invalid email") do
  fill_in "First Name", with: "John"
  fill_in "Last Name", with: "Smith"
  fill_in "Email", with: "bademail"
  fill_in "Username", with: "jsmith"
  fill_in "Password", with: "Password1!"
  fill_in "Confirm password", with: "Password1!"
end


#missing fields
When("I submit the form with missing fields") do
  fill_in "First Name", with: ""
  fill_in "Email", with: ""
  click_button "Create my account"
end


#assertions
Then("I should see the flash message {string}") do |msg|
  expect(page).to have_content(msg)
end

Then("I should still be on the registration page") do
  expect(current_path).to eq(users_path) # form submitted via POST /users
end

Then("I should be redirected to the dashboard page") do
  expect(current_path).to eq(dashboard_path)
end

Then("the password fields should be cleared") do
  expect(find_field("Password").value).to eq("")
  expect(find_field("Confirm password").value).to eq("")
end

Then("the email field should be cleared") do
  expect(find_field("Email").value).to eq("")
end
