@dsl
Feature: Resource action items

  Background:
    Given I am logged in
    And a product with sku "table"

  Scenario: Default resource action items
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    When I am on the admin products page
    Then I should see resource action items:
      | Edit | Review | Remove |

  Scenario: Define list of resource action items
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        resource_action_items :show, :edit
      end
      """
    When I am on the admin products page
    Then I should see resource action items:
      | Edit | Review |
    And I should not see resource action item "Remove"

  Scenario: Custom resource action item
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        resource_action_item do
          link_to icon('arrow-down'), '/', title: 'Custom'
        end
      end
      """
    When I am on the admin products page
    Then I should see resource action item "Custom"
