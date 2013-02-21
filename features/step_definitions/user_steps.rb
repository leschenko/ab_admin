# -*- encoding : utf-8 -*-
### UTILITY METHODS ###
def valid_user
  @user ||= {email: 'test@example.com', password: '123456'}
end

def sign_in(user)
  visit new_user_session_path
  fill_in 'Email', with: user[:email]
  fill_in 'Password', with: user[:password]
  click_button 'Sign in'
end

### GIVEN ###
Given /^I am signed out$/ do
  visit '/users/sign_out'
end

Given /^I do not exist as a user$/ do
  User.where(email: valid_user[:email]).first.should be_nil
end

Given /^I exist as a user$/ do
  FactoryGirl.create(:admin_user, valid_user)
end

When /^I sign in with valid credentials$/ do
  sign_in valid_user
end

Then /^I see an invalid login message$/ do
  page.should have_content('Invalid email or password')
end

Then /^I should be signed out$/ do
  visit '/admin'
  current_path.should == '/users/sign_in'
end

When /^I sign in with a wrong password$/ do
  sign_in valid_user.merge(password: 'wrong')
end

Then /^I see a successful sign in message$/ do
  page.should have_content('Signed in successfully')
end

Then /^I should see my name$/ do
  page.should have_content(User.where(email: valid_user[:email]).first.try(:name))
end

Given /^I am logged in$/ do
  @me = FactoryGirl.create(:admin_user, valid_user)
  login_as @me
end

Given /^I am logged in as "(.*)"$/ do |email|
  @me = FactoryGirl.create(:admin_user, valid_user.merge(email: email))
  login_as @me
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

Then /^I should see a signed out message$/ do
  page.should have_content('Signed out successfully')
end

When /^I return to the site$/ do
  current_path.should == '/'
end