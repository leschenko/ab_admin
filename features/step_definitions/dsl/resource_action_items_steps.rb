Then /^I should see resource action items:$/ do |table|
  table.raw.first.each do |link|
    expect(page).to have_css("#list td.actions_panel a[title='#{link}']")
  end
end

Then /^I should not see resource action item "(.*?)"$/ do |link|
  expect(page).not_to have_css("#list td.actions_panel a[title='#{link}']")
end

Then /^I should see resource action item "(.*?)"$/ do |link|
  expect(page).to have_css("#list td.actions_panel a[title='#{link}']")
end

