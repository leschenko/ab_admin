Given /^collection "(.*?)" with (\d+) products$/ do |collection, num|
  @collection = FactoryGirl.create(:collection, :name => collection)
  num.times { FactoryGirl.create(:product, :collection => @collection) }
end

Then /^I should see (\d+) products$/ do |num|
  all('#list tbody tr').count.should == num
end