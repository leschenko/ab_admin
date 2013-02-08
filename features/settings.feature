Feature: App settings
  In order to tune my application
  As an admin user
  I wand to customize settings

  Background:
    Given I am logged in

  Scenario: Editing user settings
    Given "config/settings/test.local.yml" contains:
      """
      mailer:
        from: no-reply@test.com
        reply_to: info@test.com
        subject_prefix: "[Dummy] "
      custom:
        integer: 111
        bool: false
        string: aaa
      """
    And I am on the edit admin settings page
    When I click "Custom"
    And I fill in the following:
      | Bool (checkbox) | check |
      | Integer         | 321   |
      | String          | Hello |
    And press "Save"

    Then the "Bool" checkbox should be checked
    And the "Integer" field should contain "321"
    And the "String" field should contain "Hello"

    Then the "custom.bool" setting should be true
    Then the "custom.integer" setting should be equal "321"
    Then the "custom.string" setting should be equal "Hello"

