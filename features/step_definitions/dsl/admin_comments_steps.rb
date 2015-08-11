Then /^I should see "(.*?)" comment with author$/ do |comment|
  within('#admin_comments') do
    page.should have_content(comment)
    page.should have_content(@me.name)
  end
end

Given /^comment "(.*?)" exists$/ do |comment|
  AdminComment.create(resource_id: @product.id, resource_type: 'Product', body: comment) do |c|
    c.user = @me
  end
end

When(/^I add admin comment "(.*?)" with attachment$/) do |comment|
  within '#new_admin_comment' do
    fill_in 'admin_comment_body', with: comment
    attach_file 'data', Rails.root.join('../../spec/factories/files/rails.png')
    click_button 'Comment'
  end
end

Then(/^I should see "(.*?)" comment with attachment$/) do |comment|
  within '#admin_comments' do
    page.should have_content(comment)
    page.should have_css('.admin_comment-item-attachment')
  end
end

When(/^I add admin comment "(.*?)" in the list$/) do |comment|
  find("#list_product_#{@product.id}").hover
  find("#list_product_#{@product.id} .list_admin_comments_link").click
  within "#list_admin_comments_product_#{@product.id}" do
    fill_in 'admin_comment_body', with: comment
    click_button 'Comment'
  end
end