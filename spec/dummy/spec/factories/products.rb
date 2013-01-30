# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    collection nil
    sku "MyString"
    price "MyString"
    is_visible false
  end
end
