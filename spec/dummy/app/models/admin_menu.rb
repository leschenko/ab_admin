class AdminMenu < AbAdmin::MenuBuilder
  draw do
    model User
    group 'System' do
      model Structure
    end
    group 'Moderator', :if => proc { moderator? } do
      link 'for moderator', 'dummy_path'
    end
    group 'Admin', :if => :admin? do
      link 'for admin', 'dummy_path'
    end
  end
end
