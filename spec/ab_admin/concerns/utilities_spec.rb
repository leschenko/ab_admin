require 'spec_helper'

RSpec.describe AbAdmin::Concerns::Utilities do
  describe 'token generation' do
    it 'generate uniq token' do
      expect(Product.generate_token(:token)).not_to be_blank
    end

    it 'generate uniq token' do
      product = build(:product)
      expect(product.generate_token(:token)).not_to be_blank
    end

    it 'generate uniq token' do
      product = create(:product)
      expect(product.generate_token(:token)).not_to be_blank
    end
  end

  describe '#ensure_token' do
    it 'store generated token' do
      product = create(:product)
      product.ensure_token(:token)
      expect(product.reload.token).not_to be_blank
    end

    it 'no db call on new record' do
      product = build(:product)
      expect(product).not_to receive(:update_column)
      product.ensure_token(:token)
    end

    it 'return existing token' do
      product = build(:product, token: 'abcd')
      expect(product).not_to receive(:generate_token)
      expect(product.ensure_token(:token)).to eq 'abcd'
    end
  end

  describe '#update_counter_column' do
    it 'update counters by sql' do
      collection = create(:collection)
      2.times { create(:product, collection: collection) }
      expect{
        Collection.update_counter_column(:products_count, :products)
      }.to change{ collection.reload.products_count }.from(0).to(2)
    end

    it 'with assoc conditions' do
      collection = create(:collection)
      create(:product, collection: collection, is_visible: false)
      create(:product, collection: collection, is_visible: true)
      expect{
        Collection.update_counter_column(:visible_products_count, :visible_products)
      }.to change{ collection.reload.visible_products_count }.from(0).to(1)
    end

    it 'consider default scope' do
      collection = create(:collection)
      create(:product, collection: collection, is_visible: true)
      create(:product, collection: collection, is_visible: true, is_deleted: true)
      expect{
        Collection.update_counter_column(:visible_products_count, :visible_products)
      }.to change{ collection.reload.visible_products_count }.from(0).to(1)
    end

    context 'has_many through' do
      it 'update counters by sql' do
        catalogue = create(:catalogue)
        2.times { create(:product, catalogues: [catalogue]) }
        expect {
          Catalogue.update_counter_column(:products_count, :products)
        }.to change { catalogue.reload.products_count }.from(0).to(2)
      end

      it 'with assoc conditions' do
        catalogue = create(:catalogue)
        2.times { create(:product, catalogues: [catalogue], is_visible: false) }
        2.times { create(:product, catalogues: [catalogue], is_visible: true) }
        expect {
          Catalogue.update_counter_column(:visible_products_count, :visible_products)
        }.to change { catalogue.reload.visible_products_count }.from(0).to(2)
      end
    end
  end
end
