@dsl @wip
Feature: Custom actions

  Background:
    Given I am logged in
    And 1 product exists

  Scenario: Custom member action
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        action_item do
          link_to 'Custom action', action_item_admin_path(:custom), method: :post
        end

        member_action :custom, method: :post do
          flash[:notice] = 'Custom action done!'
          redirect_to resource_path
        end
      end
      """
    And I am on the admin product page
    When I click "Custom action"
    Then I should see "Custom action done!"
    And I should be on the admin product page

  Scenario: Custom member action http verb check
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        action_item do
          link_to 'Custom action', action_item_admin_path(:custom)
        end

        member_action :custom, method: :post do
          flash[:notice] = 'Custom action done!'
          redirect_to resource_path
        end
      end
      """
    And I am on the admin product page
    When I should see routing error when follow "Custom action"

  Scenario: Custom collection action
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        action_item do
          link_to 'Custom collection action', action_item_admin_path(:custom_collection), method: :post
        end

        collection_action :custom_collection, method: :post do
          flash[:notice] = 'Custom collection action done!'
          redirect_to collection_path
        end
      end
      """
    And I am on the admin products page
    When I click "Custom collection action"
    Then I should see "Custom collection action done!"
    And I should be on the admin products page

