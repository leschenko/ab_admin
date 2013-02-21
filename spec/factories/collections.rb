# encoding: utf-8
FactoryGirl.define do
  factory :collection do
    name 'Expensive collection'
    description Forgery::LoremIpsum.paragraph html: true
    is_visible true
  end
end
