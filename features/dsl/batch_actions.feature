@dsl @wip @javascript
Feature: Batch actions

  Background:
    Given I am logged in
    And 3 products exists

  Scenario: Batch destroy
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    And I am on the admin products page
    When I check 2 products in the list
    And I choose batch action "Delete selected"
    Then I should see confirmation dialog

  Scenario: Batch destroy
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    And I am on the admin products page
    When I check 2 products in the list
    And I choose batch action "Delete selected"
    And I follow "Confirm"
    Then I should be on the admin products page
    And I should see 1 item in the list
