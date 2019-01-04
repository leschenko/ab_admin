@dsl @focus
Feature: Form

  Background:
    Given I am logged in

  Scenario: Form fields
    Given a configuration of:
    """
      class AbAdminProduct < AbAdmin::AbstractResource
        permitted_params :sku, :price, :is_visible, :collection_id, *Product.all_translated_attribute_names

        form do
          group :base do
            field :sku
            field :price
          end
          field :is_visible
          field :collection, as: :association
          locale_tabs do
            field :name
            field :description
          end
        end
      end
      """
    When I am on the new admin product page
    And I fill in the following:
      | * Sku                  | sofa         |
      | Price                  | 567          |
      | Display (checkbox)     | check        |
      | product_name_en        | Sofa         |
      | product_description_en | Product desc |
    And I submit form
    Then I should be on the admin products page
    And I should see "sofa"

  Scenario: Rendering default resource form template
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        permitted_params :all
      end
      """
    And "app/views/admin/products/_form.html.slim" contains:
      """
      = admin_form_for @product do |f|
        = input_set 'My custom fields' do
          = f.input :sku, label: 'Identifier'

        = f.save_buttons
      """
    When I am on the new admin product page
    And I fill in "* Identifier" with "pid-1"
    And I submit form
    Then I should be on the admin products page
    And I should see "pid-1"

  Scenario: Rendering custom form template
    Given a configuration of:
      """
      class AbAdminProduct < AbAdmin::AbstractResource
        permitted_params :all
        form partial: 'admin/products/form_custom'
      end
      """
    And "app/views/admin/products/_form_custom.html.slim" contains:
      """
      = admin_form_for @product do |f|
        = input_set 'My custom fields' do
          = f.input :sku, label: 'Identifier'

        = f.save_buttons
      """
    When I am on the new admin product page
    And I fill in "* Identifier" with "pid-1"
    And I submit form
    Then I should be on the admin products page
    And I should see "pid-1"


