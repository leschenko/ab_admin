@dsl
Feature: Actions items
  In order to perform actions on the resource
  As a logged in user
  I want to have action buttons in the page header

  Background:
    Given I am logged in
    And a product with sku "table"

  Scenario: Default action items
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
      end
      """
    When I am on the admin products page
    Then I should see an action item to "Create"

    When I am on the new admin product page
    Then I should see an action item to "Create"

    When I am on the edit admin product page
    Then I should see action items:
      | Create | Review | Remove |

    When I am on the show admin product page
    Then I should see action items:
      | Create | Edit | Remove |

  Scenario: Preview action item
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        preview_path :product_path
      end
      """
    When I am on the edit admin product page
    Then I should see an action item to "Preview"

  Scenario: Custom action item
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        action_item do
          link_to 'Main page', '/'
        end
      end
      """
    When I am on the show admin product page
    Then I should see an action item to "Main page"

  Scenario: Conditional action item
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        action_item :except => :edit, :if => proc { params[:id].present? } do
          link_to 'Secret link', '/'
        end
      end
      """
    When I am on the show admin product page
    Then I should see an action item to "Secret link"

    When I am on the edit admin product page
    Then I should not see an action item to "Secret link"

    When I am on the new admin product page
    Then I should not see an action item to "Secret link"

  Scenario: Disable default action item
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        action_item :destroy, false
      end
      """
    When I am on the show admin product page
    Then I should not see an action item to "Remove"
