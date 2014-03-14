require 'spec_helper'

describe AbAdmin::Concerns::Utilities do
  describe 'token generation' do
    it 'generate uniq token' do
      Product.generate_token(:token).should_not be_blank
    end

    it 'generate uniq token' do
      product = build(:product)
      product.generate_token(:token).should_not be_blank
    end

    it 'generate uniq token' do
      product = create(:product)
      product.generate_token(:token).should_not be_blank
    end
  end

  describe '#ensure_token' do
    it 'store generated token' do
      product = create(:product)
      product.ensure_token(:token)
      product.reload.token.should_not be_blank
    end

    it 'no db call on new record' do
      product = build(:product)
      product.should_not_receive(:update_column)
      product.ensure_token(:token)
    end

    it 'return existing token' do
      product = build(:product, token: 'abcd')
      product.should_not_receive(:generate_token)
      product.ensure_token(:token).should == 'abcd'
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
      2.times { create(:product, collection: collection, is_visible: false) }
      2.times { create(:product, collection: collection, is_visible: true) }
      expect{
        Collection.update_counter_column(:visible_products_count, :visible_products)
      }.to change{ collection.reload.visible_products_count }.from(0).to(2)
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
