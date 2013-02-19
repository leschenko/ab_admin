@locator
Feature: Locale files editor
  In order to change site localization
  As an admin
  I want to edit locale files

  Background:
    Given I am logged in
    And "config/locales/en.test.yml" contains:
    """
      en:
        site:
          title: "Dummy app"
      """
    And am on the admin locators page

  Scenario: Locale file editing
    Then I follow "en.test.yml"
    And I fill in "locale_hash_site_title" with "Great app"
    And press "Save"
    When "config/locales/en.test.yml" should contain:
      """
      en:
        site:
          title: "Great app"
      """

  Scenario: Merging locale files
    Then I follow "Prepare localization files"
    When "config/locales/ru.test.yml" should contain:
      """
      ru:
        site:
          title: ""
      """

#  Scenario: Reloading localization
#    Then I follow "Update localization"
#    When I should see "Translations successfully reloaded"
#    And i18n key "site.title" should have "Dummy app" value
