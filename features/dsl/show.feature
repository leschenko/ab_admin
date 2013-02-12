@dsl
Feature: Show resource page

  Background:
    Given I am logged in
    And products exists with attributes:
      | sku     | name      | price |
      | sofa-12 | FancySofa | 123   |

  Scenario: Default show view
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    When I am on the admin product page
    Then I should see attributes table:
      | Sku   | sofa-12   |
      | Name  | FancySofa |
      | Price | 123       |

  Scenario: Default show view
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        show do
          field :sku
          field(:price) {|item| "$#{item.price}" }
        end
      end
      """
    When I am on the admin product page
    Then I should see attributes table:
      | Sku   | sofa-12   |
      | Price | $123      |
    And I should not see "FancySofa" within "table"

