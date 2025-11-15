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

Given ("I am on the registration page") do
  visit new_user_path
end

When("I fill in the registration form with valid details") do
  fill_in "Name", with: "testuser"
  fill_in "Email", with: "example@example.com"
  fill_in "Password", with: "Password1!"
  fill_in "Birthday", with: "01/01/01"
end

When("I click the button: Create Account") do
  click_button "Create Account"
end

Then("I should see the flash message: {string}") do |msg|
  expect(page).to have_content(msg)
end

Then("I should be redirected to {string} page") do |page_name|
  case page_name.downcase
  when "dashboard"
    expect(current_path).to eq(dashboard_path)
  else
    raise "Unknown page #{page_name}"
end

end