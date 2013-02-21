@dsl @javascript
Feature: Batch actions

  Background:
    Given I am logged in
    And 3 products exists

  Scenario: Batch destroy confirmation
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    And I am on the admin products page
    When I check 2 products in the list
    And I choose batch action "Delete selected"
    Then I should see confirmation dialog

  Scenario: Batch destroy
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    And I am on the admin products page
    When I check 2 products in the list
    And I choose batch action "Delete selected"
    And I follow "Confirm"
    Then I should be on the admin products page
    And I should see 1 item in the list

  Scenario: Disable batch destroy
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        batch_action :destroy, false
      end
      """
    And I am on the admin products page
    And I click "Action"
    And I should not see "Delete selected"

  Scenario: Custom batch action as block
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        batch_action(:un_publish) { |item| item.un_publish! }
      end
      """
    And I am on the admin products page
    When I check 2 products in the list
    And I choose batch action "Unpublish selected"
    Then I should be on the admin products page
    And I should see 1 published item in the list

  Scenario: Custom batch action as symbol
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        batch_action :un_publish!, title: 'Deativate', confirm: 'Un Publish?'
      end
      """
    And I am on the admin products page
    When I check 2 products in the list
    And I choose batch action "Deativate"
    And I follow "Confirm"
    Then I should be on the admin products page
    And I should see 1 published item in the list

