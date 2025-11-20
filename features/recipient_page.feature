Feature: Recipient Management
  As a gift giver
  I want to view and manage my recipients
  So that I can track gift ideas for them

  Background:
    Given I am on the Recipients page
    Then I should see a header "My Recipients"
    And I should see a button "Add Recipient"
    And I should see the list of all recipients

  Scenario: user with no recipients added
    Given the user has no recipients added
    Then I should see no recipients in the list

  Scenario: Viewing a recipients details
    Given a recipient exists
    When I click the button "View" for that recipient
    Then I should be taken to the recipient "View" page

  Scenario: Editing a recipient
    Given a recipient exists
    When I click the button "Edit" for that recipient
    Then I should be taken to the recipient "Edit" page

  Scenario: Deleting a recipient
    Given a recipient exists
    When I click the button "Delete" for that recipient
    Then I should remain on the "Recipients" page

  Scenario: Adding a new recipient
    When I click the button "Add Recipient"
    Then I should see the new recipient form