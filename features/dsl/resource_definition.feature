@wip
Feature: Dsl resource definition

  Background:
    Given I am logged in
    And products exists with attributes:
      | sku | name  |
      | 12  | Table |
      | dc1 | Chair |

  Scenario:
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :id
          field :sku
          field :name
        end

        search do
          field :id
          field :sku
          field :name
        end
      end
      """
    When I am on the admin products page
    Then I should see list of products
    And I see search form with "Id,Sku,Name" filters
