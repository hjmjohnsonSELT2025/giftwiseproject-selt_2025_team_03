Feature: Account Creation
  As a new user
  I want to register an account
  So that I can log in and use the application

  Background:
    Given I am on the registration page
    Then I should see the registration form fields
    And I should see the button "Create my account"
    And I should see the login link

  Scenario: Successful registration
    When I fill in the registration form with valid details
    And I click the user registration button "Create my account"
    Then I should be redirected to the dashboard page

  Scenario: Invalid password entered
    When I enter an invalid password
    And I click the user registration button "Create my account"
    And the password fields should be cleared
    And I should still be on the registration page

  Scenario: Invalid email entered
    When I enter an invalid email
    And I click the user registration button "Create my account"
    And the email field should be cleared
    And I should still be on the registration page

  Scenario: Missing required fields
    When I submit the form with missing fields
    And I should still be on the registration page
