Then /^I should see "(.*?)" comment with author$/ do |comment|
  within('#admin_comments') do
    page.should have_content(comment)
    page.should have_content(@me.name)
  end
end

Given /^comment "(.*?)" exists$/ do |comment|
  AdminComment.create(:resource_id => @product.id, :resource_type => 'Product', :body => comment) do |c|
    c.author = @me
  end
end
