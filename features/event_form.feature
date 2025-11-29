Feature: Create a new Event
  As a logged-in user
  I want to create a new event
  So that I can organize gifting for specific dates

  Background:
    Given I am a logged-in user
    And the following recipients exist for my account:
      | name       |
      | Alice      |
      | Bob        |

  Scenario: Successfully create a new event with recipients
    Given I am on the New Event page
    When I fill in the event form with valid data
    And I select recipient "Alice"
    And I select recipient "Bob"
    And I submit the event form
    Then the event "Christmas Party" should exist in the database


  Scenario: Fail to create an event due to missing required fields
    Given I am on the New Event page
    When I submit the event form without filling required fields
    Then I should see "Choose who will receive gifts for this event"