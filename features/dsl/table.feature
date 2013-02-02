@dsl @wip
Feature: Resource table view

  Background:
    Given I am logged in
    And products exists with attributes:
      | sku  | price | name  |
      | t-12 | 234   | Table |
      | dc_1 | 12    | Chair |

  Scenario: Table columns
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :sku
          field :name
        end
      end
      """
    When I am on the admin products page
    Then I should see list of products

  Scenario: Columns data formatting
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :sku
          field :price
          field(:picture) { |item| item_image_link(item) }
          field :created_at
          field :is_visible
          field :collection
        end
      end
      """
    When I am on the admin products page
    Then I should see pretty formatted products

  Scenario Outline: Sortable columns
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :price
          field <config>
        end
      end
      """
    And I am on the admin products page
    When I follow "<column>"
    Then I should see products ordered by "<ordering>"

  Examples:
    | column | config                                                          | ordering |
    | Sku    | :sku                                                            | sku      |
    | Name   | :name, :sortable => :id                                         | id       |
    | Name   | :name, :sortable => {:column => :price, :default_order => 'desc'} | price desc |

  Scenario: Disabled sortable column
    Given a resource configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        table do
          field :created_at, :sortable => false
        end
      end
      """
    And I am on the admin products page
    Then I should not see "Created at" link
