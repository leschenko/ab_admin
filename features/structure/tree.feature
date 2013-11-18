Feature: Sortable tree index view

  Background:
    Given I am logged in
    And structures tree exists:
      | title   | parent_name |
      | _1_     |             |
      | _1-1_   | _1_         |
      | _1-2_   | _1_         |
      | _2_     |             |
      | _2-1_   | _2_         |
      | _2-1-1_ | _2-1_       |
    And I am on the admin structures page

  Scenario: Structure tree
    Then I should see structures tree
