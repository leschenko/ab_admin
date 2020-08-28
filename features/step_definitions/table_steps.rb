Given /^users exists with attributes:$/ do |users|
  users.hashes.each do |user|
    FactoryBot.create(:user, user)
  end
end

Then /^I should see list of users$/ do
  User.all.each do |user|
    expect(page).to have_content(user.email)
  end
end

Then /^I see search form with "(.*?)" filter$/ do |filter|
  expect(page).to have_field(filter)
  # within '#search_form' do
  # end
end

Given /^I see search form with "(.*?)" filters$/ do |filters|
  filters.split(',').each do |filter|
    step %{I see search form with "#{filter}" filter}
  end
end

Given(/^I hover first item$/) do
  page.execute_script('$("#list tbody tr:first").addClass("test-hover")')
end
