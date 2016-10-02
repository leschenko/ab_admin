@dsl
Feature: Resource history page
  In order to view resource history
  As a logged in user
  I want to see resource history page

  Background:
    Given I am logged in
    And a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        permitted_params :all
        settings history: true
      end
      """
    And a product with history

  Scenario: History action item
    When I am on the admin product page
    Then I should see an action item to "History"

  Scenario: View resource history
    When I am on the admin product page
    And I click "History" within ".resource_actions"
    Then I should be on the history admin product page
    And I should see resource history
