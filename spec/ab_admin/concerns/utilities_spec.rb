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
end
