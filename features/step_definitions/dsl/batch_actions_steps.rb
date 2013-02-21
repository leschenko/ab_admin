Given /^(\d+) products? exists$/ do |n|
  n.to_i.times{ @product = FactoryGirl.create(:product) }
end

When /^I check (\d+) products in the list$/ do |n|
  Product.limit(n.to_i).pluck(:id).each do |p_id|
    check("batch_action_item_#{p_id}")
  end
end

Then /^I should see confirmation dialog$/ do
  find('#confirmation_dialog').should be_visible
end

When /^I choose batch action "(.*?)"$/ do |action|
  find('.batch_actions .dropdown-toggle').click
  find('.dropdown-menu a', text: action).click
end

Then /^I should see (\d+) item in the list$/ do |n|
  all('#list tbody tr').count.should == n.to_i
end

Then /^I should see (\d+) published item in the list$/ do |n|
  all('#list .badge-success').count.should == n.to_i
end

