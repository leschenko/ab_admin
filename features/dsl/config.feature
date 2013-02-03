@dsl
Feature: Configuring resource options

  Background:
    Given I am logged in
    And a product with sku "table"

  Scenario: Search form fields
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        preview_path :product_path
      end
      """
    When I am on the admin products page
    And I follow "Preview"
    Then I should see "sku - table"

  Scenario: Search form fields
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        preview_path {|product| product_path(product) }
      end
      """
    When I am on the admin products page
    And I follow "Preview"
    Then I should see "sku - table"
