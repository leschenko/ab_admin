When /^I fill in place with "(.*?)"$/ do |value|
  find('#list .editableform input').set(value)
end

When /^I submit in place form$/ do
  find('#list .editableform .editable-submit').click()
end
