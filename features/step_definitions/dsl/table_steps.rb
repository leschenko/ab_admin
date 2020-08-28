Given /^a product with sku "(.*?)"$/ do |sku|
  @product = FactoryBot.create(:product, sku: sku)
end

Given /^products? exists with attributes:$/ do |products|
  products.hashes.each do |attrs|
    @product = FactoryBot.create(:full_product, attrs)
  end
end

Then /^I should see list of products$/ do
  Product.all.each do |product|
    expect(page).to have_content(product.sku)
    expect(page).to have_content(product.name)
  end
end

Then /^I should see products ordered by "(.*?)"$/ do |order|
  method = order.to_s.split.first.to_sym
  have_ordered_list Product.order(order).map { |p| p.send(method) }
end

Then /^I should see pretty formatted products$/ do
  product = Product.first

  within '#list' do
    expect(page).to have_content(product.sku)
    expect(page).to have_content(product.price)
    expect(page).to have_css('span.badge', text: '+')
    expect(page).to have_link(product.collection.name)
    expect(page).to have_css("img[src='#{product.picture.url(:thumb)}']")
  end
end

Then /^I should not see "(.*?)" link$/ do |link|
  expect(page).not_to have_link(link)
end
