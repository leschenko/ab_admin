When(/^I create product$/) do
  expect {
    step 'I am on the new admin product page'
    step 'I fill in "Sku" with "table"'
    step 'I submit form'
  }.to change { Product.count }.by(1)
  @product = Product.last
end

When(/^I edit product$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I destroy product$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I batch un_publish product$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^Resource should have track with attributes:$/) do |track_attrs|
  track = Track.last
  attrs = track_attrs.hashes.first.symbolize_keys
  track.key.should == attrs[:key]
  track.name.should == attrs[:name]
  track.user.try(:name) == attrs[:user]
  track.owner.try(:name) == attrs[:owner]
end
