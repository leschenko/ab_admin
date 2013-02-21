require 'spec_helper'

describe User do

  describe 'associations' do
    it { should have_one(:avatar) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should_not allow_value('blah').for(:email) }
    it { should allow_value('a@b.com').for(:email) }
    it { should_not allow_value('123').for(:password) }
    it { should allow_value('123456').for(:password) }
    it { should_not allow_value(5).for(:user_role_id) }
  end

  describe 'attributes' do
    it 'allow mass assignment of user data attributes' do
      [:password, :password_confirmation, :email, :remember_me,
       :login, :first_name, :last_name, :patronymic, :phone, :skype, :web_site, :address, :birthday,
       :time_zone, :locale, :bg_color].each do |attr|
        should allow_mass_assignment_of(attr)
      end
    end
    it 'allow mass assignment of user_role_id, trust_state only for admin' do
      [:user_role_id, :trust_state].each do |attr|
        should_not allow_mass_assignment_of(attr)
        should allow_mass_assignment_of(attr).as(:admin)
      end
    end
  end

  describe 'scopes' do
    before(:all) do
      @user = create(:default_user)
      @moderator = create(:moderator_user)
      @inactive = create(:user)
    end

    it 'search for managers' do
      User.managers.should_not include(@user)
      User.managers.should include(@moderator)
    end

    it 'search for active users' do
      User.active.should include(@user)
      User.managers.should_not include(@inactive)
    end
  end

  context 'after create' do
    before :all do
      @user = create(:default_user)
      @admin = create(:admin_user)
      @moderator = create(:moderator_user)
      @inactive = create(:user, email: 'test@example.com')
    end

    before :each do
      @user.reload
      @admin.reload
      @moderator.reload
      @inactive.reload
    end

    it '#title' do
      @inactive.name.should == @inactive.email
      @user.name.should == @user.full_name
    end

    it '#full_name' do
      @user.full_name.should == "#{@user.first_name} #{@user.last_name}"
    end

    it 'set user defaults' do
      @inactive.user_role_id.should == ::UserRoleType.default.id
      @inactive.trust_state.should == ::UserState.pending.id
      @inactive.locale.should == 'ru'
      @inactive.time_zone.should == 'Kiev'
    end

    it 'generate login' do
      @inactive.login.should == 'test'
    end

    describe 'auth' do
      it '#generate_password!' do
        new_pass = @user.generate_password!
        @user.valid_password?(new_pass).should be_true
      end

      it 'activate user' do
        @inactive.activate
        @inactive.trust_state.should == ::UserState.active.id
        @inactive.locked_at.should be_nil
      end

      it 'activate! user' do
        @inactive.activate!
        @inactive.reload
        @inactive.trust_state.should == ::UserState.active.id
        @inactive.locked_at.should be_nil
        @inactive.should be_confirmed
      end

      it 'should set default role' do
        @inactive.reload
        @inactive.user_role_id = nil
        @inactive.save
        @inactive.user_role_id.should == ::UserRoleType.default.id
      end

      it 'pending by default' do
        @inactive.reload
        @inactive.should be_pending
        @inactive.inactive_message.should == :unconfirmed
      end

      it 'active for authentication' do
        @user.should be_active_for_authentication
      end

      it 'suspend user' do
        @user.suspend!
        @user.reload
        @user.trust_state.should == ::UserState.suspended.id
      end

      it 'delete user' do
        @user.delete!
        @user.reload
        @user.trust_state.should == ::UserState.deleted.id
        @user.should be_deleted
      end

      it 'delete user' do
        @user.unsuspend!
        @user.reload
        @user.trust_state.should == ::UserState.active.id
      end

      describe 'roles' do
        it 'default' do
          @user.should be_default
        end

        it 'moderator' do
          @moderator.should be_moderator
          @admin.should be_moderator
        end

        it 'admin' do
          @admin.should be_admin
        end
      end
    end
  end
end
