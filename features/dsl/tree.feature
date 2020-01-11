@dsl
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

  Scenario: Index view as tree
    Given a configuration of:
      """
      class AbAdminCatalogue < AbAdmin::AbstractResource
        settings index_views: [:tree]
      end
      """
    And I am on the admin catalogues page
    Then I should see catalogues tree

  Scenario: Custom node view
    Given a configuration of:
      """
      class AbAdminCatalogue < AbAdmin::AbstractResource
        settings index_views: [:tree]

        tree do |node|
          link_to "Custom node title", root_path, class: 'tree-item_link'
        end
      end
      """
    And I am on the admin catalogues page
    Then I should see "Custom node title"
