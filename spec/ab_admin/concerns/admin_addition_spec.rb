require 'spec_helper'

describe AbAdmin::Concerns::AdminAddition do

  describe '#new_changes' do
    before do
      @product = create(:product, name: 'test', price: 100)
    end

    it 'return only new values' do
      @product.price = 200
      @product.new_changes.should == {'price' => 200}
    end

    it 'omit translated attrs without locale suffix' do
      @product.name = 'new ame'
      @product.new_changes.should be_blank
    end

    it 'translated attrs with locale suffix' do
      @product.name_ru = 'new name'
      @product.new_changes.should == {name_ru: 'new name'}
    end
  end

end