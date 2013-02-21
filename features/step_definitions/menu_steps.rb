Given /^a menu configuration of:$/ do |config|
  eval config
end

Then /^I should see menu item for "(.*?)" with path "(.*?)"$/ do |name, path|
  page.should have_css("header.navbar li a[href='#{path}']", text: name)
end

Then /^I should see group "(.*?)" with menu item for "(.*?)"$/ do |group, name|
  page.should have_css('header.navbar li.dropdown a', text: group)
  page.should have_css('header.navbar ul.dropdown-menu a', text: name)
end

