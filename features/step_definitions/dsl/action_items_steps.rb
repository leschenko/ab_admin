Then /^I should see an action item link to "([^"]*)"$/ do |link|
  page.should have_css('.resource_actions a', :text => link)
end

Then /^I should not see an action item link to "([^"]*)"$/ do |link|
  page.should_not have_css('.resource_actions a', :text => link)
end

Then /^I should see an action item links:$/ do |table|
  table.raw.first.each do |link|
    page.should have_css('.resource_actions a', :text => link)
  end
end
