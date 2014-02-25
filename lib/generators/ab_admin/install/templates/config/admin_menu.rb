class AdminMenu < AbAdmin::Menu::Builder
  draw do
    link :dashboard, '/admin'

    model User
    group :system do
      model Structure
      link Locator.model_name.human, '/admin/locators'
      link Settings.model_name.human, edit_admin_settings_path
    end
  end
end
