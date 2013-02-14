class AdminMenu < AbAdmin::MenuBuilder
  draw do
    model Collection

    model User
    group :system do
      model Structure
      link Locator.model_name.human, '/admin/locators'
      link Settings.model_name.human, edit_admin_settings_path
    end
    group 'Moderator', :if => proc { moderator? } do
      link 'for moderator', 'dummy_path'
    end
    group 'Admin', :if => :admin? do
      link 'for admin', 'dummy_path'
    end
  end
end
