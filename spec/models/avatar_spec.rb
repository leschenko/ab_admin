require 'spec_helper'

describe Avatar do
  before(:all) do
    AvatarUploader.enable_processing = true
    @avatar = build(:asset_avatar)
  end

  after(:all) do
    AvatarUploader.enable_processing = false
  end

  it 'should create a new instance given valid attributes' do
    @avatar.save!
  end

  context 'validations' do
    it 'should not be valid without data' do
      pending 'asset data validations dont work on presence_of'
      @avatar.data = nil
      @avatar.should_not be_valid
    end

    it 'should not be valid with not image content-type' do
      @avatar.data_content_type = 'unknown type'
      @avatar.should_not be_valid
    end

    it 'should not be valid with big size image' do
      @avatar = build(:asset_avatar_big)
      @avatar.should_not be_valid
      @avatar.errors[:data].first.should =~ /is\stoo\sbig/
    end
  end

  context 'after create' do
    before(:each) do
      @avatar = create(:asset_avatar)
    end

    it 'filename should be valid' do
      @avatar.filename.should == 'rails.png'
    end

    it 'content-type should be valid' do
      @avatar.data_content_type.should == 'image/png'
    end

    it 'file size should be valid' do
      @avatar.data_file_size.should == 6428
    end

    it 'should be image' do
      @avatar.image?.should be_true
    end

    it 'data_file_name should be valid' do
      @avatar.data_file_name.should == 'rails.png'
    end

    it 'width and height should be valid' do
      if @avatar.has_dimensions?
        @avatar.width.should == 50
        @avatar.height.should == 64
      end
    end

    it 'urls should be valid' do
      @avatar.url.should == "/uploads/#{@avatar.class.to_s.underscore}/#{@avatar.id}/rails.png"
      @avatar.thumb_url.should == "/uploads/#{@avatar.class.to_s.underscore}/#{@avatar.id}/thumb_rails.png"
      @avatar.data.default_url.should == '/assets/defaults/avatar.png'
    end
  end

  context 'cropping' do
    before(:each) do
      @avatar = create(:asset_avatar)
      @avatar.cropper_geometry = '50,64,10,10'
    end

    it 'should construct cropping geometry' do
      @avatar.cropper_geometry.should == ['50', '64', '10', '10']
      @avatar.cropper_geometry_changed?.should == true
    end

    it 'should set image dimensions before process' do
      @avatar.width.should == 50
      @avatar.height.should == 64
      @avatar.data.dimensions.should == [50, 64]
    end

    context 'reprocess' do
      before(:each) do
        @avatar.save
      end

      it 'should crop image by specific geometry' do
        @avatar.width.should == 40
        @avatar.height.should == 54
        @avatar.data.dimensions.should == [40, 54]
      end
    end
  end

  context 'renaming', :focus => true do
    before(:each) do
      @avatar = create(:asset_avatar)
    end

    it 'rename file' do
      old_name = @avatar.data_file_name
      @avatar.rename!
      @avatar.data_file_name.should_not == old_name
    end

  end

  context 'rotation', :focus => true do
    before(:each) do
      @avatar = create(:asset_avatar)
    end

    it 'rotate image' do
      @avatar.data.dimensions.should == [50, 64]
      @avatar.rotate!
      @avatar.data.dimensions.should == [64, 50]
      @avatar.width.should == 64
      @avatar.height.should == 50
    end
  end

  context 'rotate' do

    it 'should set property correctly' do
      @avatar.rotate_degrees.should == '-90'
      @avatar.rotate_degrees_changed?.should == true
    end

    it 'should set image dimensions before process' do
      @avatar.width.should == 50
      @avatar.height.should == 64
      @avatar.data.dimensions.should == [50, 64]
    end

    context 'reprocess' do
      before(:each) do
        @avatar.save
      end

      it 'should rotate image by degrees' do
        @avatar.width.should == 64
        @avatar.height.should == 50
        @avatar.data.dimensions.should == [64, 50]
      end
    end
  end
end
