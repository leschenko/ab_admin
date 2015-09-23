@dsl @javascript
Feature: Admin comments
  
  Background: 
    Given I am logged in
    And 1 product exists

  Scenario: Adding a comment
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings comments: true
      end
      """
    And I am on the edit admin product page
    When I fill in "admin_comment_body" with "Hello"
    And I press "Comment"
    Then I should see "Hello" comment with author

  Scenario: Adding a comment with attachment
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings comments: true
      end
      """
    And I am on the edit admin product page
    When I add admin comment "Comment with attachment" with attachment
    Then I should see "Comment with attachment" comment with attachment

  Scenario: Adding a list comment
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings comments: {list: true}
      end
      """
    And I am on the admin products page
    When I add admin comment "List comment" in the list
    Then I should see "List comment" comment with author

  Scenario: Deleting a comment
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        settings comments: true
      end
      """
    And comment "Hello" exists
    And I am on the edit admin product page
    When I click "Remove" within "#admin_comments"
    Then I should not see "Hello"

