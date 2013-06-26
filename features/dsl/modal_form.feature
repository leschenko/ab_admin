@javascript @dsl @fancy_select @focus @wip
Feature: ModalForm

  Background:
    Given I am logged in

  Scenario: Form fields
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        form do
          field :sku
          field :collection, as: :string, fancy: true, input_html: {data: {add: '/admin/collections/new', collection: [{id: 1, text: 'test'}]*10}}
        end
      end

      class AbAdminCollection < AbAdmin::AbstractResource
        modal_form do
          field :name
          field :is_visible
        end
      end
      """
    When I am on the new admin product page
    And pause
    And I fill in the following:
      | Sku        | sofa                    |
      | Collection | missing collection name |
    Then I should see "Add missing collection name"