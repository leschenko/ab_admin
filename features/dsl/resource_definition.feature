@wip
Feature: Dsl resource definition

  Background:
    Given I am logged in
    And products exists with attributes:
      | sku | name  |
      | 12  | Table |
      | dc1 | Chair |

  Scenario: Resource table definition
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :sku
          field :name
        end
      end
      """
    When I am on the admin products page
    Then I should see list of products

  Scenario: Resource table sortable columns
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :sku
          field :name, :sortable => :id
          field :created_at, :sortable => false
        end
      end
      """
    And I am on the admin products page
    When I follow "Name"
    Then I should see products ordered by "id"



#  Scenario: Resource table definition
#    Given a resource configuration of:
#      """
#      class AbAdminProduct < AbAdmin::AbstractResource
#        table do
#          field :id
#          field :sku
#          field :name
#        end
#
#        search do
#          field :id
#          field :sku
#          field :name
#        end
#      end
#      """
#    When I am on the admin products page
#    Then I should see list of products
#    And I see search form with "Id,Sku,Name" filters
