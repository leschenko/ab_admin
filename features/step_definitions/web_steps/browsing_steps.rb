### GIVEN ###
Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

### WHEN ###
When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
end

### THEN ###
Then /^I should be redirected to (.+)$/ do |page|
  puts 'TODO: make this done'
  step "I should be on #{page}"
end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  page.should have_content(text)
end

Then /^(?:|I )should not see "([^"]*)"$/ do |text|
  page.should have_no_content(text)
end

Then /^(?:|I )should see \/([^\/]*)\/([imxo])?$/ do |regexp,flags|
  regexp_opts = [regexp,flags].compact
  regexp = Regexp.new(*regexp_opts)

  page.should have_xpath('//*', :text => regexp)
end

Then /^(?:|I )should not see \/([^\/]*)\/([imxo])?$/ do |regexp,flags|
  regexp_opts = [regexp,flags].compact
  regexp = Regexp.new(*regexp_opts)

  page.should have_no_xpath('//*', :text => regexp)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  current_path.should == path_to(page_name)
end

Then /^I should see (\d+) elements? kind of (.+)$/ do |count, locator|
  actual_count = all(selector_for(locator)).count
  count = count.to_i

  actual_count.should eq(count)
end

Then /^I should not see elements? kind of (.+)$/ do |locator|
  page.should_not have_css(selector_for(locator))
end
