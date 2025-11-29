#Feature: Add a new recipient
#  As a user
#  I want to add a recipient
#  So that I can manage gift ideas for them
#
#  Background:
#    Given I am logged in
#    And I am on the Add New Recipient page
#
#  Scenario: Successfully add a recipient
#    When I fill in "Name" with "Alex"
#    And I select "Friend" from "Relationship"
#    And I fill in "Birthday" with "01/01/2025"
#    And I fill in "Interests & likes" with "Books, Hiking"
#    And I fill in "Avoid" with "Chocolate"
#    And I click "Save recipient"
#
#  Scenario: Attempt to add recipient without required fields
#    When I click "Save recipient"
#    Then I should see "can't be blank"