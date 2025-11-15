Feature: Account Creation


  Background:
    Given I am on the registration page
    Then I should see the button: Create Account
    And I should see the fillable field: name, email, password, birthday, occupation, likes, dislikes
    And I should see link on the bottom: "Already have an account? Login"


  Scenario:
    When I enter all the necessary information correctly
    And I click the button: Create Account
    Then I should see the flash message: "Account Created"
    And I should be redirected to "Dashboard" page


  Scenario: invalid password entered
    When I enter a password that does not meet requirements
    Then I should see the flash message: “Invalid Password: Password should be at least 8 characters, contain at least one letter, symbol and number”
    And my password field should be emptied
    And I should be prompted to enter the password again


  Scenario: invalid age entered
    When I enter an age that does not meet requirements, 0-115
    Then I should see the flash message: “Invalid Age: Please enter a valid age”
    And my age field should be emptied
    And I should be prompted to enter the age again


  Scenario: invalid email entered
    When I enter an email that does not meet requirements
    Then I should see the flash message: “Invalid Email: Please enter a valid email”
    And my email field should be emptied
    And I should be prompted to enter the email again