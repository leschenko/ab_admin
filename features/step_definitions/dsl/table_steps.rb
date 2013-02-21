Given /^a product with sku "(.*?)"$/ do |sku|
  @product = FactoryGirl.create(:product, sku: sku)
end

Given /^products? exists with attributes:$/ do |products|
  products.hashes.each do |attrs|
    @product = FactoryGirl.create(:full_product, attrs)
  end
end

Then /^I should see list of products$/ do
  Product.all.each do |product|
    page.should have_content(product.sku)
    page.should have_content(product.name)
  end
end

Then /^I should see products ordered by "(.*?)"$/ do |order|
  method = order.to_s.split.first.to_sym
  have_ordered_list Product.order(order).map { |p| p.send(method) }
end

Then /^I should see pretty formatted products$/ do
  product = Product.first

  within '#list' do
    page.should have_content(product.sku)
    page.should have_content(product.price)
    page.should have_content(I18n.l(product.created_at, format: :long))
    page.should have_css('span.badge', text: '+')
    page.should have_link(product.collection.name)
    page.should have_css("img[src='#{product.picture.url(:thumb)}']")
  end
end

Then /^I should not see "(.*?)" link$/ do |link|
  page.should_not have_link(link)
end
