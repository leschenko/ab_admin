@dsl @javascript
Feature: In place edit

  Background:
    Given I am logged in
    And a product with sku "sofa-12"
    And a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        permitted_params :all

        table do
          field :sku, editable: true
          field :name
          field :created_at
        end
      end
      """
    And I am on the admin products page

  Scenario: In place edit field
    When I click "sofa-12"
    And I fill in place with "sofa_new"
    And I submit in place form
    Then I should see "sofa_new"

    When I reload the page
    Then I should see "sofa_new"
