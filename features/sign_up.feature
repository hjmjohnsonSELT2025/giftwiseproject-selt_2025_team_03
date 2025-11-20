Feature: User Registration
    As a new user
    I want to create an account with my personal information
    So that I can start planning gifts and get personalized suggestions

    Background:
        Given I am on the login page
        Then I should see the button: login, register
        And I should see the fillable field: username, password

    Scenario: first time user seeking to register
        When I click the button: register
        Then I should see the "registration" page

    Scenario: user successfully signing in
        When I fill in the fillable field: username, password
        And I click the button: login
        And the following fillable fields are valid: username, password
        Then I should see the "Dashboard" page

    Scenario: user unsuccessfully signing in
        When I fill in the fillable field: username, password
        And I click the button: login
        And then the following fillable fields are not valid: username, password
        Then I should see the flash message claiming “Invalid login”
        And I should see the “login” page


