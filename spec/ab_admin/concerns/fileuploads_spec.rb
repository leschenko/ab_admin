require 'spec_helper'

describe AbAdmin::Concerns::Fileuploads do
  before(:all) do
    @picture = create(:picture)
  end

  it 'return asset class' do
    expect(Structure.fileupload_klass('picture')).to eq Picture
  end
  
  it 'find asset by guid' do
    asset = Structure.fileupload_find('picture', @picture.guid)
    expect(asset).to eq @picture
  end

  it 'update asset target_id by guid' do
    Structure.fileupload_update(1000, @picture.guid, :picture)
    @picture.reload
    expect(@picture.assetable_id).to eq 1000
    expect(@picture.guid).to be_nil
  end

  context 'instance methods' do
    before(:each) do
      @structure = build(:structure_page)
    end

    it 'generate guid' do
      expect(@structure.fileupload_guid).not_to be_blank
    end

    it 'change guid' do
      @structure.fileupload_guid = 'other guid'
      expect(@structure.fileupload_changed?).to be_truthy
      expect(@structure.fileupload_guid).to eq 'other guid'
    end

    it 'not be multiple' do
      expect(@structure.fileupload_multiple?('picture')).to be_falsey
    end

    it 'find uploaded asset or build new record' do
      picture = @structure.fileupload_asset(:picture)
      expect(picture).not_to be_nil
      expect(picture).to be_new_record
    end

    it 'return fileuploads columns' do
      @structure.fileuploads_columns.should include(:picture)
    end
  end

end
