@dsl @wip
Feature: Scope view to parent resource

  Background:
    Given I am logged in

  Scenario:
    Given collection "Expensive" with 2 products
    And a product with sku "sofa-9"
    And a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        belongs_to :collection
      end
      """
    Then I am on the collection products page
    And I should see 2 products
    And I should not see "sofa-9"