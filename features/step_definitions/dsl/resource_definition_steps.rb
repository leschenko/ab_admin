Given /^products exists with attributes:$/ do |products|
  products.hashes.each do |product|
    Product.create(product)
  end
end

Then /^I should see list of products$/ do
  Product.all.each do |product|
    page.should have_content(product.sku)
    page.should have_content(product.name)
  end
end

Then /^I should see products ordered by "(.*?)"$/ do |order|
  within '#list' do
    all('td:nth-child(4)').map(&:text).should == Product.order(order).map(&:name)
  end
end
