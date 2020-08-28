Then /^the "(.*?)" setting should be true$/ do |setting|
  expect(Settings.data.dig(*setting.split('.').map(&:to_sym))).to be_truthy
end

Then /^the "(.*?)" setting should be equal "(.*?)"$/ do |setting, value|
  expect(Settings.data.dig(*setting.split('.').map(&:to_sym))).to eq YAML.load(value.to_s)
end