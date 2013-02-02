# encoding: utf-8
FactoryGirl.define do
  factory :product do
    sku 'dc1/234'
    price 123
    name 'Table'
    description Forgery::LoremIpsum.paragraph :html => true
    is_visible true

    factory :full_product do
      association :collection
      after(:build) do |product|
        product.picture = create(:picture, :assetable => product)
      end
    end
  end
end
