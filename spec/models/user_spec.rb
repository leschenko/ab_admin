require 'spec_helper'

describe User do
  before(:all) do
    @user = FactoryGirl.build(:default_user)
  end
  
  it "should create a new instance given valid attributes" do
    @user.save!
  end
    
  context "validations" do
    it "should not be valid with empty name" do
      @user.name = nil
      @user.should_not be_valid
    end
    
    it "should not be valid with empty email" do
      @user.email = nil
      @user.should_not be_valid
    end
    
    it "should not be valid with invalid email" do
      @user.email = 'wrong'
      @user.should_not be_valid
    end
    
    it "should not be valid with invalid password" do
      @user.password = '123'
      @user.should_not be_valid
    end
  end
  
  context "after create" do
    before(:each) do
      @user = FactoryGirl.create(:default_user)
    end
    
    it 'should search users by email' do
      # TODO: not working in mongoid
      #User.with_email(@user.email.split(/@/).first).first.should == @user
      User.with_email(@user.email).first.should == @user
    end
    
    it "should search users by role" do
      User.with_role(::RoleType.default).all.should include(@user)
    end
    
    it "export users in csv format" do
      User.to_csv.should include([@user.id,@user.email,@user.name,@user.current_sign_in_ip].join(','))
    end
    
    it "export users in csv format with custom columns" do
      options = { :columns => [:id, :email, :confirmed_at, :created_at ] }
      User.to_csv(options).should include([@user.id,@user.email,@user.confirmed_at,@user.created_at].join(','))
    end
    
    it "should set default role" do
      @user.role_type_id.should == RoleType.default.id
      @user.role_symbol.should == RoleType.default.code
    end
    
    it "should return current user events" do
      @user.confirmed_at = nil
      @user.lock_access!
      
      @user.events_for_current_state.should include('unlock')
      @user.events_for_current_state.should include('activate')
    end
  end
end
