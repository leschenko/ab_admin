# -*- encoding : utf-8 -*-
### UTILITY METHODS ###
def valid_user
  @user ||= {:email => 'test@example.com', :password => '123456'}
end

def sign_in(user)
  visit new_user_session_path
  fill_in 'Email', :with => user[:email]
  fill_in 'Password', :with => user[:password]
  click_button 'Sign in'
end

### GIVEN ###
Given /^I am logged out$/ do
  visit '/users/sign_out'
end

Given /^I do not exist as a user$/ do
  User.where(:email => valid_user[:email]).first.should be_nil
end

Given /^I exist as a user$/ do
  FactoryGirl.create(:default_user, valid_user)
end

When /^I sign in with valid credentials$/ do
  sign_in valid_user
end

Then /^I see an invalid login message$/ do
  page.should have_content('asd')
end

Then /^I should be signed out$/ do
  visit '/admin'
  current_path.should == '/users/sign_in'
end

When /^I sign in with a wrong password$/ do
  sign_in valid_user.merge(:password => 'wrong')
end

Then /^I see a successful sign in message$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be on the dashboard page$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see my name$/ do
  pending # express the regexp above with the code you wish you had
end