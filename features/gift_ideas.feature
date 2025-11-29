Feature: Gift Ideas Management
  As a logged-in user
  I want to view and add gift ideas
  So that I can manage my gifts efficiently

  Background:
    Given I am logged in as a user

  Scenario: Viewing the Gift Ideas page
    Given the following gift ideas exist:
      | title         | price | status     | url           | notes       | event_recipient_id |
      | Teddy Bear    | 25    | idea       | http://bear.com | Soft toy   | 1                 |
      | Board Game    | 40    | purchased  | http://board.com | Fun game  | 2                 |
    When I visit the gift ideas page
    Then I should see "Teddy Bear"
    And I should see "Board Game"

  Scenario: Empty state when no gifts exist
    Given no gift ideas exist
    When I visit the gift ideas page
    Then I should see message "No upcoming gifts or events. Create your first event or gift to get started!"

  Scenario: Adding info on a new gift
    Given I am on the add new gift page
    When I fill in gift idea field "Title" with "Puzzle"
    And I fill in gift idea field "Price" with "30"
    And I select gift idea field "idea" from "Status"
    And I fill in gift idea field "Url Link" with "http://puzzle.com"
    And I fill in gift idea field "Notes" with "Challenging puzzle"
    And I fill in gift idea field "ID of the Recipient" with "3"

