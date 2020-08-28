Then /^I should see an action item to "([^"]*)"$/ do |link|
  expect(page).to have_css('.resource_actions a', text: link)
end

Then /^I should not see an action item to "([^"]*)"$/ do |link|
  expect(page).not_to have_css('.resource_actions a', text: link)
end

Then /^I should see action items:$/ do |table|
  table.raw.first.each do |link|
    expect(page).to have_css('.resource_actions a', text: link)
  end
end
