@dsl @focus
Feature: Resource history tracking
  In order to save history of resource changes
  Every resource change should be saved

  Background:
    Given I am logged in
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings history: true
        batch_action(:un_publish) { |item| item.un_publish! }
      end
      """

  Scenario: Track resource create
    When I create product
    Then Resource should have track with attributes:
      | key             | name   | user  | owner |
      | products.create | Create | admin | admin |

  Scenario: Track resource edit
    Given a product with sku "table"
    When I edit product
    Then Resource should have track with attributes:
      | key           | name | user  | owner |
      | products.edit | Edit | admin | admin |

  Scenario: Track resource destroy
    When I destroy product
    Then Resource should have track with attributes:
      | key              | name    | user  | owner |
      | products.destroy | Destroy | admin | admin |

  Scenario: Track resource batch action
    When I batch un_publish product
    Then Resource should have track with attributes:
      | key                       | name      | user  | owner |
      | products.batch_un_publish | UnPublish | admin | admin |



