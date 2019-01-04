module ControllerMacros
  def login_admin
    before(:all) do
      @admin = FactoryBot.create(:admin_user)
    end
    
    before(:each) do
      sign_out :user
      sign_in @admin
    end
  end
  
  def login_default
    before(:all) do
      @user = FactoryBot.create(:default_user)
    end
    
    before(:each) do
      sign_out :user
      sign_in @user
    end
  end
  
  def login_redactor
    before(:all) do
      @user = FactoryBot.create(:redactor_user)
    end
    
    before(:each) do
      sign_out :user
      sign_in @user
    end
  end
  
  def login_moderator
    before(:all) do
      @user = FactoryBot.create(:moderator_user)
    end
    
    before(:each) do
      sign_out :user
      sign_in @user
    end
  end
  
  def user_logout
    before(:each) do
      sign_out :user
    end
  end
end
