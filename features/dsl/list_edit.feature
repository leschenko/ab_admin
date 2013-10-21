@dsl @javascript
Feature: Editing records in the list

  Background:
    Given I am logged in
    And a product with sku "sofa-12"
    And a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings list_edit: true
      end
      """
    And I am on the admin products page

  Scenario: Saving record with valid attributes
    Given I click "Edit"
    Then I should be on the admin products page
    And I fill in "Sku" with "new_sofa" within "#list"
    And I submit form
    When I should see "new_sofa"
    And I should not see "Save"

  Scenario: Saving record with invalid attributes
    Given I click "Edit"
    Then I should be on the admin products page
    And I fill in "Sku" with "" within "#list"
    And I submit form
    When I should see "Sku can't be blank"
    And I should see "Save"

  Scenario: Creating record with valid attributes
    Given I click "Create" within ".resource_actions"
    Then I should be on the admin products page
    And I fill in "Sku" with "new_sofa" within "#list"
    And I submit form
    When I should see "new_sofa"
    And I should not see "Save"

  Scenario: Creating record with invalid attributes
    Given I click "Create" within ".resource_actions"
    Then I should be on the admin products page
    And I fill in "Sku" with "" within "#list"
    And I submit form
    When I should see "Sku can't be blank"
    And I should see "Save"
