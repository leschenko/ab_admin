@dsl
Feature: Resource history tracking
  In order to save history of resource changes
  Every resource change should be saved

  Background:
    Given I am logged in
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        permitted_params :all
        settings history: true
        batch_action(:un_publish) { |item| item.un_publish! }
      end
      """

  Scenario: Track resource create
    When I create product
    Then Resource should have track with attributes:
      | key             | action_title | user  | owner |
      | products.create | Creation     | admin | admin |

  Scenario: Track resource edit
    Given a product with sku "table"
    When I edit product
    Then Resource should have track with attributes:
      | key             | action_title | user  | owner |
      | products.update | Editing      | admin | admin |

  Scenario: Track resource destroy
    Given a product with sku "table"
    When I destroy product
    Then Resource should have track with attributes:
      | key              | action_title | user  | owner |
      | products.destroy | Removal      | admin | admin |

  Scenario: Track resource batch action
    Given a product with sku "table"
    When I batch un_publish product
    Then Resource should have track with attributes:
      | key                       | action_title | user  | owner |
      | products.batch_un_publish | Multi-hiding | admin | admin |



