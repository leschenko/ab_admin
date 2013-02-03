@dsl
Feature: Export

  Background:
    Given I am logged in
    And products exists with attributes:
      | sku  | price | name  |
      | t-12 | 234   | Table |
      | dc_1 | 12    | Chair |

  Scenario: Search form fields
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        export do
          field :sku
          field :price
          field :name
          field :is_visible
          field :collection
          field :created_at
        end
      end
      """
    When I am on the admin products page
    And I follow "export_csv"
    Then should see "t-12"
    And should see "234"
    And should see "Chair"
