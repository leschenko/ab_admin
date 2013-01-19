# encoding: utf-8
require 'spec_helper'

describe Structure do
  it_should_behave_like 'headerable'
  it_should_behave_like 'nested_set'

  it { should respond_to(:structure_type) }
  it { should respond_to(:position_type) }
  it { should respond_to(:friendly_id_config) }

  describe 'associations' do
    it { should have_many(:visible_children).class_name('Structure') }
    it { should have_one(:static_page) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title)  }
    it { should validate_numericality_of(:position).only_integer  }
  end

  describe 'attributes' do
    it 'allow mass assignment for structure data attributes' do
      [:kind, :position, :parent_id, :title, :redirect_url, :is_visible,
       :structure_type, :position_type, :slug, :parent].each do |attr|
        should allow_mass_assignment_of(attr)
      end
    end
  end

  context 'acts_as_nested_set' do
    before(:all) do
      @root = create(:structure_main)
      @structure = create(:structure_page, :parent => @root)
    end

    before(:each) do
      @structure.reload
      @root.reload
    end

    it 'set parent model' do
      @structure.parent.should == @root
    end

    it 'moveable' do
      @structure.should be_moveable
    end

    it 'not moveable if root' do
      @root.should_not be_moveable
    end

    it 'moveable if new record' do
      Structure.new.should be_moveable
    end

    it 'return deep parent' do
      child = build(:structure_page, :parent => @structure)
      child.deep_parent.should == @root
    end

    it 'count descendants' do
      @structure.descendants_count.should == 0
      @root.descendants_count.should == 1
    end
  end

end
