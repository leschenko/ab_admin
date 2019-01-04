Given '{int} products exists' do |n|
  n.to_i.times{ @product = FactoryBot.create(:product) }
end

When 'I check {int} products in the list' do |n|
  Product.limit(n.to_i).pluck(:id).each do |p_id|
    check("batch_action_item_#{p_id}")
  end
end

Then /^I should see confirmation dialog$/ do
  page.should have_selector('.bootbox.modal.fade.in')
end

When /^I choose batch action "(.*?)"$/ do |action|
  find('.content_actions .dropdown-toggle').click
  find('.dropdown-menu a', text: action).click
end

When 'I set zoom {int}' do |zoom|
  fill_in 'batch_params_zoom', with: zoom
end

When /^I submit batch action form/ do
  find('.js-batch_form_submit').click
end

Then 'I should see {int} item in the list' do |n|
  all('#list tbody tr').count.should == n.to_i
end

Then 'I should see {int} published item in the list' do |n|
  all('#list .badge-success').count.should == n.to_i
end

Then /^I should see fancybox with set_zoom_batch_form$/ do
  expect(page).to have_selector('.fancybox-inner #set_zoom_batch_form')
end

Then 'I should see {int} items in the list with zoom {int}' do |items_count, zoom|
  expect(page).to have_selector('#list tr td:nth-child(9)', text: zoom, count: items_count)
end


