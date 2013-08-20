When /^I fill in place with "(.*?)"$/ do |value|
  find('.editableform input').set(value)
end

When /^I submit in place form$/ do
  find('.editableform .editable-submit').click()
end
