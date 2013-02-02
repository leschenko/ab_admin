@dsl
Feature: Export

  Background:
    Given I am logged in

  Scenario: Search form fields
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        form do
          field :sku
          field :price
          field :is_visible
          field :collection
          locale_tabs do
            field :name
            field :description
          end
        end
      end
      """
    When I am on the new admin product page
    And I fill in the following:
      | Sku                    | t-1          |
      | Price                  | 567          |
      | Display                | check        |
      | product_name_en        | Sofa         |
      | product_description_en | Product desc |
    And I press "Save"
    Then I should be on the admin products page
    And I should see "Sofa"
