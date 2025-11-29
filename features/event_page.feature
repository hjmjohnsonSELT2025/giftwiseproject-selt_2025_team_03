#Feature: Events List
#  As a gift giver
#  I want to see all my events
#  So that I can view, edit, delete, or add events
#
#  Background:
#    Given I am on the Events page
#
#  Scenario: Displaying all events
#    Given the following events exist:
#      | Name           | Date       | Recipients       |
#      | Alice's Birthday | 2025-05-10 | Alice           |
#      | Christmas       | 2025-12-25 | Family          |
#    Then I should see "Alice's Birthday" in the event list
#    And I should see "Christmas" in the event list
#    And each event should have buttons "View, Edit, Delete"
#
#  Scenario: Navigating to add a new event
#    When I click the button "Add Event"
#    Then I should be taken to the "New Event" page
#
#  Scenario: Viewing event details
#    Given an event exists with name "Alice's Birthday"
#    When I click "View" on the "Alice's Birthday" event
#    Then I should see the event name "Alice's Birthday"
#    And I should see the date "2025-05-10"
#    And I should see recipients "Alice"
#
#  Scenario: Editing an event
#    Given an event exists with name "Christmas"
#    When I click "Edit" on the "Christmas" event
#    And I fill in "Event Name" with "Family Christmas"
#    And I click the button "Save"
#    Then I should see "Family Christmas" in the event list
#    Then I should not see "Christmas" in the event list
#
#  Scenario: Deleting an event
#    Given an event exists with name "Alice's Birthday"
#    When I click "Delete" on the "Alice's Birthday" event
#    Then I should not see "Alice's Birthday" in the event list
