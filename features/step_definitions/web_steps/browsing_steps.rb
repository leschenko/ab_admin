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

When /^(?:|I )click "([^"]*)"$/ do |link|
  click_link(link)
end

### THEN ###
Then /^I should be redirected to (.+)$/ do |page|
  patiently do
    current_path.should == path_to(page_name)
  end
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

  page.should have_xpath('//*', text: regexp)
end

Then /^(?:|I )should not see \/([^\/]*)\/([imxo])?$/ do |regexp,flags|
  regexp_opts = [regexp,flags].compact
  regexp = Regexp.new(*regexp_opts)

  page.should have_no_xpath('//*', text: regexp)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  sleep 0.3
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

def have_ordered_list(lines)
  lines = lines.collect { |line| line.to_s.gsub(/\s+/, ' ') }.collect(&:strip).reject(&:blank?)
  pattern = lines.collect(&Regexp.method(:quote)).join('.*?')
  pattern = Regexp.compile(pattern)
  page.find('body').text.gsub(/\s+/, ' ').should =~ pattern
end

# Checks that these strings are rendered in the given order in a single line or in multiple lines
#
# Example:
#
#       Then I should see in this order:
#         | Alpha Group |
#         | Augsburg    |
#         | Berlin      |
#         | Beta Group  |
#
Then /^I should see in this order:?$/ do |text|
  if text.is_a?(String)
    lines = text.split(/\n/)
  else
    lines = text.raw.flatten
  end
  have_ordered_list(lines)
end

Then /^I should see an error$/ do
  (400 .. 599).should include(page.status_code)
end

Then /^I should not see an error$/ do
  (200..399).should include(page.status_code)
end

When /^I reload the page$/ do
  case Capybara::current_driver
    when :selenium
      visit page.driver.browser.current_url
    when :racktest
      visit [current_path, page.driver.last_request.env['QUERY_STRING']].reject(&:blank?).join('?')
    when :culerity
      page.driver.browser.refresh
    else
      raise 'unsupported driver, use rack::test or selenium/webdriver'
  end
end