@dsl
Feature: Resource history sidebar
  In order to view resource history during editing
  As a logged in user
  I want to see resource history sidebar on the edit page

  Background:
    Given I am logged in
    And a product with history

  Scenario: History action item with sidebar config
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings history: {sidebar: true}
      end
      """
    When I am on the edit admin product page
    Then I should not see an action item to "History"

    When I am on the admin products page
    Then I should not see resource action item "History"

  Scenario: Resource history in sidebar
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings history: {sidebar: true}
      end
      """
    When I am on the edit admin product page
    Then I should see resource history bar



