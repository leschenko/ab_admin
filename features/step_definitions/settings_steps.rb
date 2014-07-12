Then /^the "(.*?)" setting should be true$/ do |setting|
  configatron.to_hash.val(*setting.split('.').map(&:to_sym)).should be_truthy
end

Then /^the "(.*?)" setting should be equal "(.*?)"$/ do |setting, value|
  configatron.to_hash.val(*setting.split('.').map(&:to_sym)).should == YAML.load(value.to_s)
end