require 'spec_helper'

describe AbAdmin::Concerns::Fileuploads do
  before(:all) do
    @picture = create(:picture)
  end

  it 'return asset class' do
    Structure.fileupload_klass('picture').should == Picture
  end
  
  it 'find asset by guid' do
    asset = Structure.fileupload_find('picture', @picture.guid)
    asset.should == @picture
  end

  it 'update asset target_id by guid' do
    Structure.fileupload_update(1000, @picture.guid, :picture)
    @picture.reload
    @picture.assetable_id.should == 1000
    @picture.guid.should be_nil
  end

  context 'instance methods' do
    before(:each) do
      @structure = build(:structure_page)
    end

    it 'generate guid' do
      @structure.fileupload_guid.should_not be_blank
    end

    it 'change guid' do
      @structure.fileupload_guid = 'other guid'
      @structure.fileupload_changed?.should be_truthy
      @structure.fileupload_guid.should == 'other guid'
    end

    it 'not be multiple' do
      @structure.fileupload_multiple?('picture').should be_falsey
    end

    it 'find uploaded asset or build new record' do
      picture = @structure.fileupload_asset(:picture)
      picture.should_not be_nil
      picture.should be_new_record
    end

    it 'return fileuploads columns' do
      @structure.fileuploads_columns.should include(:picture)
    end
  end

end
