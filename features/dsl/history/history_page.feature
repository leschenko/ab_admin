@dsl
Feature: Resource history page
  In order to view resource history
  As a logged in user
  I want to see resource history page

  Background:
    Given I am logged in
    And a product with history

  Scenario: History action item
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings history: true
      end
      """
    When I am on the admin product page
    Then I should see an action item to "History"

    When I am on the admin products page
    Then I should see resource action item "History"

  Scenario: View resource history
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings history: true
      end
      """
    When I am on the admin product page
    And I click "History" within ".resource_actions"
    Then I should be on the history admin product page
    And I should see resource history


