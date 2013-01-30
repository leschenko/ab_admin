@wip
Feature: Menu

  Background:
    Given I am logged in

  Scenario: Show menu tree
    Given i18n key "admin.navigation.system" with value "System menu"
    And i18n key "admin.navigation.for_admin" with value "for admin"
    And a menu configuration of:
    """
      AbAdmin::MenuBuilder.draw do
        model User
        group :system do
          model Structure
        end
        group 'Moderator', :if => proc { moderator? } do
          link 'for moderator', 'dummy_path'
        end
        group 'Admin', :if => :admin? do
          link 'for admin', 'dummy_path'
        end
      end
      """
    When I am on the dashboard page
    Then I should see menu item for "User"
    And I should see group "System menu" with menu item for "Structure"
    And I should see group "Moderator" with menu item for "for moderator"
    And I should see group "Admin" with menu item for "for admin"
