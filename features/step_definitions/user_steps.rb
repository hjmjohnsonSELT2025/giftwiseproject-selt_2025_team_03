#####################################Login Page#############################################
Given("I am on the login page") do
  visit login_path
end


Then("I should see the button: login, register") do
  expect(page).to have_button("Login")
  expect(page).to have_link("Register")
end


Then("I should see the fillable field: username, password") do
  expect(page).to have_field("username")
  expect(page).to have_field("password")
end


When("I fill in the fillable field: username, password") do
  fill_in "username", with: "testuser"
  fill_in "password", with: "Password1!"
end


When("I click the button: login") do
  click_button "Login"
end


When("I click the button: register") do
  click_link "Register"
end


Then("I should see the {string} page") do |page_name|
  case page_name.downcase
  when "registration"
    expect(current_path).to eq(new_user_path)
  when "dashboard"
    expect(current_path).to eq(dashboard_path)
  else
    raise "Unknown page #{page_name}"
  end
end


################### Registration Page #############################################


# features/step_definitions/registration_steps.rb

Given("I am on the registration page") do
  visit new_user_path
end

Then("I should see the button: Create Account") do
  expect(page).to have_button("Create Account")
end

Then("I should see the fillable field: name, email, password, birthday, occupation, likes, dislikes") do
  expect(page).to have_field("name")
  expect(page).to have_field("email")
  expect(page).to have_field("password")
  expect(page).to have_field("birthday")
  expect(page).to have_field("occupation")
  expect(page).to have_field("likes")
  expect(page).to have_field("dislikes")
end

Then('I should see link on the bottom: {string}') do |link_text|
  expect(page).to have_link(link_text)
end

When("I enter all the necessary information correctly") do
  fill_in "name", with: "Test User"
  fill_in "email", with: "test@example.com"
  fill_in "password", with: "Password1!"
  fill_in "birthday", with: "2000-01-01"
  fill_in "occupation", with: "Engineer"
  fill_in "likes", with: "Coding"
  fill_in "dislikes", with: "Bugs"
end

When("I click the button: Create Account") do
  click_button "Create Account"
end

Then('I should see the flash message: {string}') do |message|
  expect(page).to have_text(message)
end

Then('I should be redirected to {string} page') do |page_name|
  case page_name.downcase
  when "dashboard"
    expect(current_path).to eq(dashboard_path)
  else
    raise "Unknown page #{page_name}"
  end
end

When("I enter a password that does not meet requirements") do
  fill_in "password", with: "short"
end

Then("my password field should be emptied") do
  expect(find_field("password").value).to eq("")
end

Then("I should be prompted to enter the password again") do
  expect(page).to have_field("password")
end

When("I enter an age that does not meet requirements, {int}-{int}") do |min, max|
  fill_in "birthday", with: "1800-01-01" # intentionally invalid age
end

Then("my age field should be emptied") do
  expect(find_field("birthday").value).to eq("")
end

Then("I should be prompted to enter the age again") do
  expect(page).to have_field("birthday")
end

When("I enter an email that does not meet requirements") do
  fill_in "email", with: "invalid-email"
end

Then("my email field should be emptied") do
  expect(find_field("email").value).to eq("")
end

Then("I should be prompted to enter the email again") do
  expect(page).to have_field("email")
end

