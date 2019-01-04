# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :header do
    title {'seo title'}
    description {'seo description'}
    keywords {'seo, keywords'}
    seo_block {'seo seo_block'}
    h1 {'seo h1'}
    headerable_id {0}
    headerable_type {''}
  end
end
