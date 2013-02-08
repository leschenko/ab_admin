@wip
Feature: App settings
  In order to tune my application
  As an admin user
  I wand to customize settings

  Background:
    Given I am logged in

  Scenario: Adding of a new setting
    Given I am on the admin settings page
    When I add new string setting "Param" with value "custom"
    And press "Save"
    Then I should see "Param"