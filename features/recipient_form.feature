Feature: Add New Recipient Form
  As a gift giver
  I want to add new recipients with detailed info
  So that the AI can give personalized gift suggestions

  Background:
    Given I am on the New Recipient form

  Scenario: Form displays required fields
    Then I should see a field "Name"
    And I should see a field "Age"
    And I should see a field "Relationship"
    And I should see a field "Likes"
    And I should see a field "Dislikes"
    And I should see a field "Hobbies"
    And I should see a button "Save"
    And I should see a button "Cancel"

  Scenario: Successfully saving a valid recipient
    When I fill in "Name" with "John Doe"
    And I fill in "Age" with "30"
    And I fill in "Relationship" with "Friend"
    And I fill in "Likes" with "Books, Hiking"
    And I fill in "Dislikes" with "Loud noises"
    And I fill in "Hobbies" with "Guitar"
    And I click the button "Save"
    Then I should be taken to the "Recipients" page
    And I should see "John Doe" in the recipient list

  Scenario: Cancel button returns to recipients list
    When I click the button "Cancel"
    Then I should be taken to the "Recipients" page

  Scenario: Form validation errors
    When I fill in "Name" with ""
    And I click the button "Save"
    Then I should see a validation error for "Name"
