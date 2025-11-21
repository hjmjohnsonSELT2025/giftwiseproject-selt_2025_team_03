Feature: Add Event
  As a gift giver
  I want to create events and associate recipients with them
  So that I can track important dates and gift ideas

  Background:
    Given I am on the New Event form

  Scenario: Form displays all required fields
    Then I should see a dropdown "Event Type"
    And the dropdown should contain: "Holiday, Birthday, Wedding, Custom"

    And I should see a field "Event Name"
    And I should see a field "Event Date"
    And I should see a field "Recipients"
    And I should see a button "Add Recipient"
    And I should see a button "Remove Recipient"
    And I should see a text box "Extra Info"
    And I should see a checkbox "Collaborate"
    And I should see a button "Save"
    And I should see a button "Cancel"

  Scenario: Successfully creating an event
    When I select "Birthday" from the "Event Type" dropdown
    And I fill in "Event Name" with "Alice's Birthday"
    And I fill in "Event Date" with "2025-05-10"
    And I add a recipient named "Alice"
    And I fill in "Extra Info" with "She likes flowers."
    And I check "Collaborate"
    And I click the button "Save"
    Then I should be taken to the "Events" page
    And I should see "Alice's Birthday" in the event list

  Scenario: Cancel button returns to events page
    When I click the button "Cancel"
    Then I should be taken to the "Events" page"

  Scenario: Validation error for missing event name
    When I select "Holiday" from the "Event Type" dropdown
    And I fill in "Event Name" with ""
    And I fill in "Event Date" with "2025-12-25"
    And I click the button "Save"
    Then I should see a validation error for "Event Name"

  Scenario: Adding and removing recipients
    When I add a recipient named "John"
    And I add a recipient named "Mary"
    Then I should see "John" listed as a selected recipient
    And I should see "Mary" listed as a selected recipient
    When I remove the recipient named "John"
    Then I should not see "John" listed as a selected recipient
