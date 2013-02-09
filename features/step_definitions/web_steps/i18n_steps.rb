Given /^i18n key "(.*?)" with value "(.*?)"$/ do |keys, value|
  data = {}.store_multi(value, *keys.split('.'))
  I18n.backend.store_translations(I18n.locale, data)
end

When /^i18n key "(.*?)" should have "(.*?)" value$/ do |key, value|
  I18n.t(key).should == value
end
