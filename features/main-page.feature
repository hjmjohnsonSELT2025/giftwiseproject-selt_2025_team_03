Feature: Main Page

  Background:
    Given I am on the main page
    Then I should see the buttons: Events, Recipients, Gift Ideas, Profile
    And I should see a list of recent activity

  Scenario: User seeking to see their events
    When I click the button "Events"
    Then I should see the "Events" page

  Scenario: User seeking to see their recipients
    When I click the button "Recipients"
    Then I should see the "Recipients" page

  Scenario: User looking for gift ideas
    When I click the button "Gift Ideas"
    Then I should see the "Gift Ideas" page

  Scenario: User looking to update their profile
    When I click the button "Profile"
    Then I should see the "Profile" page
