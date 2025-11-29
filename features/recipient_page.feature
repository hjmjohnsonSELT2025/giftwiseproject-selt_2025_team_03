Feature: Manage recipients
  As a user
  I want to view, search, and add recipients
  So that I can organize gift information

  Background:
    Given a test user exists with username "testuser", password "password", first name "Test", and last name "User"
    And I am logged in as "testuser"

  Scenario: View recipients list
    Given the following recipients exist:
      | Name      | Relationship | Likes         |
      | Mom       | Parent       | Gardening     |
      | Alex      | Sibling      | Gaming        |
    When I visit the recipients page
    Then I should see recipient "Mom"
    And I should see recipient "Alex"

  Scenario: Search for a recipient
    Given the following recipients exist:
      | Name      | Relationship | Likes     |
      | Grandpa   | Relative     | Fishing   |
      | Sarah     | Friend       | Reading   |
    When I visit the recipients page
    And I fill in "search-recipients" with "Grandpa"
    Then I should see recipient "Grandpa"
    And I should not see recipient "Sarah"

  Scenario: Add a new recipient
    When I visit the add new recipient page
    And I fill in "recipient_name" with "Uncle Joe"
    And I select "Relative" from "recipient_relationship"
    And I fill in "recipient_likes" with "Golf"
    And I click "Save recipient"
    Then I should see recipient "Uncle Joe"
