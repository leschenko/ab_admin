Given /^users exists with attributes:$/ do |users|
  users.hashes.each do |user|
    FactoryGirl.create(:user, user)
  end
end

Then /^I should see list of users$/ do
  User.all.each do |user|
    page.should have_content(user.email)
  end
end

Given /^a resource configuration of:$/ do |config|
  eval config
end

Then /^I see search form with "(.*?)" filter$/ do |filter|
  within '#search_form' do
    page.should have_field(filter)
  end
end

Given /^I see search form with "(.*?)" filters$/ do |filters|
  filters.split(',').each do |filter|
    step %{I see search form with "#{filter}" filter}
  end
end
