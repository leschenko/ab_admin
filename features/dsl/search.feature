@dsl
Feature: Search

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
        search do
          field :sku
          field :name
          field :is_visible
          field :collection
          field :created_at
        end
      end
      """
    When I am on the admin products page
    Then I see search form with "Sku,Name,Display,Collection,Created at" filters

  Scenario: Searching
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        search do
          field :sku
        end
      end
      """
    When I am on the admin products page
    And I fill in "Sku" with "dc"
    And I press "Filter"
    Then I should see "dc_1"
    And I should not see "t-12"

