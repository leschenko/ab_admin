require 'spec_helper'

RSpec.describe Structure, type: :model do
  it_should_behave_like 'headerable'
  it_should_behave_like 'nested_set'

  it { is_expected.to respond_to(:structure_type) }
  it { is_expected.to respond_to(:position_type) }
  it { is_expected.to respond_to(:simple_slug_options) }

  describe 'associations' do
    it { is_expected.to have_many(:visible_children).class_name('Structure') }
    it { is_expected.to have_one(:static_page) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:position_type_id).only_integer  }
  end

  context 'acts_as_nested_set' do
    before(:all) do
      @root = create(:structure_main)
      @structure = create(:structure_page, parent: @root)
    end

    before(:each) do
      @structure.reload
      @root.reload
    end

    it 'set parent model' do
      expect(@structure.parent).to eq @root
    end

    it 'moveable' do
      expect(@structure).to be_moveable
    end

    it 'not moveable if root' do
      expect(@root).not_to be_moveable
    end

    it 'moveable if new record' do
      expect(Structure.new).to be_moveable
    end

    it 'return deep parent' do
      child = build(:structure_page, parent: @structure)
      expect(child.deep_parent).to eq @root
    end

    it 'count descendants' do
      expect(@structure.descendants_count).to eq 0
      expect(@root.descendants_count).to eq 1
    end
  end

end
