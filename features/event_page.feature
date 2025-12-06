Feature: Events List
  As a gift giver
  I want to see all my events
  So that I can view, edit, delete, or add events

  Background:
    Given I am logged in as a user

  Scenario: Displaying all events
    Given the following events exist:
      | Name             | Date       | Recipients | Location   | Budget |
      | Alice's Birthday | 2025-05-10 | Alice      | Restaurant | 200    |
      | Christmas        | 2025-12-25 | Family     | Home       | 1000   |
    And I am on the Events page
    Then I should see "Alice's Birthday" in the event list
    And I should see "Christmas" in the event list
    And each event should have buttons "View, Edit, Delete"

  Scenario: Viewing empty events list
    Given the user has no events added
    And I am on the Events page
    Then I should see no events in the list
    And I should see a message "No events yet"

  Scenario: Navigating to add a new event
    Given I am on the Events page
    When I click the button "Add Event"
    Then I should be taken to the "New Event" page

  Scenario: Viewing event details
    Given an event exists with name "Alice's Birthday"
    And I am on the Events page
    When I click "View" on the "Alice's Birthday" event
    Then I should see the event details page
    And I should see the event name "Alice's Birthday"
    And I should see the date "May 10, 2025"

  Scenario: Editing an event
    Given an event exists with name "Christmas"
    And I am on the Events page
    When I click "Edit" on the "Christmas" event
    Then I should be taken to the edit event page
    When I fill in "Event Name" with "Family Christmas"
    And I click the button "Save"
    Then I should be redirected to the Events page
    And I should see "Family Christmas" in the event list
    And I should not see "Christmas" in the event list

  Scenario: Deleting an event
    Given an event exists with name "Alice's Birthday"
    And I am on the Events page
    When I click "Delete" on the "Alice's Birthday" event
    Then I should not see "Alice's Birthday" in the event list
    And I should see a message "Event deleted"

  Scenario: Search for events by name
    Given the following events exist:
      | Name             | Date       | Location   |
      | Christmas        | 2025-12-25 | Home       |
      | Birthday Party   | 2025-06-15 | Restaurant |
      | Anniversary      | 2025-08-20 | Beach      |
    And I am on the Events page
    When I search for "Christmas"
    Then I should see "Christmas" in the event list
    And I should not see "Birthday Party" in the event list
    And I should not see "Anniversary" in the event list

  Scenario: Search for events by location
    Given the following events exist:
      | Name           | Date       | Location   |
      | Christmas      | 2025-12-25 | Home       |
      | Birthday Party | 2025-06-15 | Restaurant |
    And I am on the Events page
    When I search for "Restaurant"
    Then I should see "Birthday Party" in the event list
    And I should not see "Christmas" in the event list

  Scenario: Viewing events as different users
    Given another user exists with events
    And I am on the Events page
    Then I should not see the other user's events
