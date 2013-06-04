When(/^I create product$/) do
  expect {
    step 'I am on the new admin product page'
    step 'I fill in "Sku" with "table"'
    step 'I submit form'
  }.to change { Product.count }.by(1)
  @product = Product.last
end

When(/^I edit product$/) do
  step 'I am on the edit admin product page'
  step 'I fill in "Sku" with "chair"'
  step 'I submit form'
end

When(/^I destroy product$/) do
  step 'I am on the edit admin product page'
  step 'I click "Remove"'
end

When(/^I batch un_publish product$/) do
  post('/admin/products/batch', ids: [@product.id], batch_action: 'un_publish')
end

Then(/^Resource should have track with attributes:$/) do |track_attrs|
  track = Track.last
  attrs = track_attrs.hashes.first.symbolize_keys
  track.key.should == attrs[:key]
  track.action_title.should == attrs[:action_title]
  track.user.try(:name) == attrs[:user]
  track.owner.try(:name) == attrs[:owner]
end

Given(/^a product with history$/) do
  step 'a product with sku "table"'
  @product.track! key: :create, user: @me
  @product.track! key: :update, user: @me
end

Then(/^I should see resource history$/) do
  within 'table' do
    @product.tracks.each do |track|
      page.should have_content(track.name)
    end
  end
end

Then(/^I should see resource history bar$/) do
  within '.sidebar.abs_bar' do
    @product.tracks.each do |track|
      page.should have_content(I18n.l(track.created_at, format: :short))
    end
  end
end