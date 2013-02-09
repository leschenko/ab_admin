class AdminMenu < AbAdmin::MenuBuilder
  draw do
    model User
    group :system do
      model Structure
      model Locator
      model Settings, :url => edit_admin_settings_path
    end
  end
end
