Feature: User Login
  As a returning user
  I want to log in
  So that I can access my dashboard

  Background:
    Given a user exists with username "testuser" and password "password123"
    And I am on the login page

  Scenario: Login page displays expected fields and buttons
    Then I should see the field "Username"
    And I should see the field "Password"
    And I should see the button "Login"
    And I should see the link "Register"

  Scenario: Register link redirects to the registration page
    When I click the link "Register"
    Then I should be on the registration page

  Scenario: Successful login redirects to dashboard
    When I fill in login field with "Username" with "testuser"
    And I fill in login field with "Password" with "password123"
    And I click the login field button "Login"
    Then I should be on the dashboard page

  Scenario: Unsuccessful login redirects to dashboard
    When I fill in login field with "Username" with "testuser"
    And I fill in login field with "Password" with "wrongPassword"
    And I click the login field button "Login"
    Then I should be on the login page