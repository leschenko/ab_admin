@dsl
Feature: Export

  Background:
    Given I am logged in
    And products exists with attributes:
      | sku  | price | name  |
      | t-12 | 234   | Table |
      | dc_1 | 12    | Chair |
    And a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        export do
          field :sku
          field(:price) { |item| "$#{item.price}" }
          field :name
          field :is_visible
          field :collection
          field :created_at
        end
      end
      """

  Scenario: Export to csv format
    When I am on the admin products page
    And I follow "export_csv"
    Then should see "t-12"
    And should see "$234"
    And should see "Chair"

#  Scenario: Export to json format
#    When I am on the admin products page
#    And I follow "export_json"
#    Then should see "t-12"
#    And should see "234"
#    And should see "Chair"

  Scenario: Export to xls format
    When I am on the admin products page
    And I follow "export_xlsx"
    Then I should not see an error

