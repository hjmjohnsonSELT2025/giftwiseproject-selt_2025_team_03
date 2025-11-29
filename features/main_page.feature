Feature: Main Page

  Background:
    Given I am on the dashboard
    Then I should see the buttons: "Events, Recipients, Gift Ideas, Settings"
    And I should see a list of recent activity

  Scenario: User seeking to see their events
    When I click the dashboard button "Events"
    Then I should see the "Events" page

  Scenario: User seeking to see their recipients
    When I click the dashboard button "Recipients"
    Then I should see the "Recipients" page

  Scenario: User looking for gift ideas
    When I click the dashboard button "Gift Ideas"
    Then I should see the "Gift Ideas" page

  Scenario: User looking to update their profile
    When I click the dashboard button "Profile"
    Then I should see the "Profile" page

  Scenario: User looking to update their settings
    When I click the dashboard button "Settings"
    Then I should see the "Settings" page

  Scenario: User looking to logout
    When I click the dashboard button "Logout"
    Then I should see the "Sign in" page
