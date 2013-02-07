Then /^I should see resource action items:$/ do |table|
  table.raw.first.each do |link|
    page.should have_css("#list td.actions a[title='#{link}']")
  end
end

Then /^I should not see resource action item "(.*?)"$/ do |link|
  page.should_not have_css("#list td.actions a[title='#{link}']")
end

Then /^I should see resource action item "(.*?)"$/ do |link|
  page.should have_css("#list td.actions a[title='#{link}']")
end

