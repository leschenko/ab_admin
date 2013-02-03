@dsl
Feature: Configuring resource options

  Background:
    Given I am logged in
    And a product with sku "table"

  Scenario: Preview path as symbol
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        preview_path :product_path
      end
      """
    When I am on the admin products page
    And I follow "Preview"
    Then I should see "sku - table"

  Scenario: Preview path as block
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        preview_path {|product| product_path(product) }
      end
      """
    When I am on the admin products page
    And I follow "Preview"
    Then I should see "sku - table"

  Scenario Outline: List allowed actions
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        actions <config>
      end
      """
    And I should not see routing error on the admin products page
    And I should see routing error on the new admin product page

  Examples:
    | config            |
    | :index            |
    | :except => :new   |
    | :except => [:new] |