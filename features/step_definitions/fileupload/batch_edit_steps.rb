Given(/^I have avatar$/) do
  @me.avatar = FactoryGirl.create(:avatar, assetable: @me)
end

When(/^I click image batch edit button$/) do
  find('.fileupload-edit-button').click()
end

Then(/^I should see edit image meta form$/) do
  page.should have_selector('form.fileupload-edit-form input[placeholder="Alt"]')
end

When(/^I fill in image meta$/) do
  within 'form.fileupload-edit-form' do
    click_link I18n.locale.to_s.titleize
    find(".tab_#{I18n.locale} input[placeholder=\"Alt\"]").set('Alt text')
    find(".tab_#{I18n.locale} input[placeholder=\"Name\"]").set('Title text')
  end
end

When(/^I submit image meta form$/) do
  within '.bootbox.modal' do
    click_link 'Save'
  end
end

Then(/^image should store meta$/) do
  image = @me.reload.avatar
  image.alt.should == 'Alt text'
  image.name.should == 'Title text'
end

