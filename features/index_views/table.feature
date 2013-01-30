Feature: Table view
  Background:
    Given I am logged in as "test@example.com"
    And users exists with attributes:
      | email            | first_name |
      | bob@example.com  | Bob        |
      | alex@example.com | Alex       |
      | jack@example.com | Jack       |
    And I am on the admin users page

  Scenario: List of users
    Then I should see list of users

  Scenario: Filtering users
    Given I see search form with "Email" filter
    When I fill in "Email" with "bob"
    And I press "Filter"
    Then I should see "bob@example.com"
    And I should not see "alex@example.com"

