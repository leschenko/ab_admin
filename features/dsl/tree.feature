@dsl @wip
Feature: Sortable tree index view

  Background:
    Given I am logged in
    And catalogues tree exists:
      | title   | parent_name |
      | _1_     |             |
      | _1-1_   | _1_         |
      | _1-2_   | _1_         |
      | _2_     |             |
      | _2-1_   | _2_         |
      | _2-1-1_ | _2-1_       |

  Scenario: Structure tree
    Given a configuration of:
      """
      class AbAdminCatalogue < AbAdmin::AbstractResource
        settings :index_view => 'tree'
      end
      """
    And I am on the admin catalogues page
    Then I should see catalogues tree
