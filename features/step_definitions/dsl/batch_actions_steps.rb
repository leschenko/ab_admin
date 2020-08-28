Given '{int} products exists' do |n|
  n.to_i.times{ @product = FactoryBot.create(:product) }
end

When 'I check {int} products in the list' do |n|
  Product.limit(n.to_i).pluck(:id).each do |p_id|
    check("batch_action_item_#{p_id}")
  end
end

Then /^I should see confirmation dialog$/ do
  expect(page).to have_selector('.bootbox.modal.fade.in')
end

When /^I choose batch action "(.*?)"$/ do |action|
  all('.content_actions .dropdown-toggle').first.click
  find('.dropdown-menu a', text: action).click
end

Then 'I should see {int} item in the list' do |n|
  expect(all('#list tbody tr').count).to eq n.to_i
end

Then 'I should see {int} published item in the list' do |n|
  expect(all('#list .badge-success').count).to eq n.to_i
end
