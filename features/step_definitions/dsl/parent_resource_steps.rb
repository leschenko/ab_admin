Given 'collection {string} with {int} products' do |collection, num|
  @collection = FactoryBot.create(:collection, name: collection)
  num.times { FactoryBot.create(:product, collection: @collection) }
end

Then 'I should see {int} products' do |num|
  expect(all('#list tbody tr').count).to eq num
end
