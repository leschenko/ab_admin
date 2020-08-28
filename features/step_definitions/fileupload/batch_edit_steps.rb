Given(/^I have avatar$/) do
  @me.avatar = FactoryBot.create(:avatar, assetable: @me)
end

When(/^I click image batch edit button$/) do
  page.execute_script "window.scrollBy(0,10000)"
  find('.fileupload-edit-button').click()
end

Then(/^I should see edit image meta form$/) do
  expect(page).to have_selector('form.fileupload-edit-form input[placeholder="Alt"]')
end

When(/^I fill in image meta$/) do
  within 'form.fileupload-edit-form' do
    click_link I18n.locale.to_s
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
  expect(image.alt).to eq 'Alt text'
  expect(image.name).to eq 'Title text'
end
