require 'spec_helper'

class UploaderSpecImageUploader < AbAdmin::CarrierWave::BaseUploader
  version :thumb do
    process resize_to_fill: [40, 40]
  end
end

class UploaderSpecImage < Asset
  ab_admin_uploader UploaderSpecImageUploader

  validates :data_content_type, inclusion: {in: AbAdmin.image_types}
  validates_integrity_of :data
  validates_filesize_of :data, maximum: 1.megabyte

  class_attribute :stub_build_filename

  def data_secure_token
    'abc'
  end

  def build_filename(_, record=nil)
    stub_build_filename || 'custom_filename'
  end
end

class UploaderSpecModel < RspecActiveModelBase
end


describe AbAdmin::CarrierWave::BaseUploader do
  before :all do
    UploaderSpecImageUploader.enable_processing = true
    @assetable = UploaderSpecModel.new(id: 1)
  end

  after :all do
    UploaderSpecImageUploader.enable_processing = false
  end

  around do |example|
    I18n.with_locale(:ru) { example.run }
  end

  context 'naming' do
    describe 'file names' do
      before do
        @image = create(:uploader_spec_image, assetable: @assetable)
      end

      context 'full name' do
        it 'include secure_token' do
          File.basename(@image.data.url).should == 'abc.png'
          File.basename(@image.class.find(@image.id).data.url).should == 'abc.png'
        end
      end

      context 'version name' do
        it 'only version name' do
          File.basename(@image.data.url(:thumb)).should == 'thumb.png'
          File.basename(@image.class.find(@image.id).data.url(:thumb)).should == 'thumb.png'
        end
      end
    end

    describe '#store_dir' do
      it 'create subdirectories from id' do
        @image = create(:uploader_spec_image, id: 12345678, assetable: @assetable)
        @image.data.store_dir.should == 'uploads/uploader_spec_image/123/45678'
      end

      it 'create subdirectories from id 2' do
        @image = create(:uploader_spec_image, id: 1, assetable: @assetable)
        @image.data.store_dir.should == 'uploads/uploader_spec_image/000/1'
      end
    end

    describe 'store original filename' do
      it 'stored in original_name field' do
        @image = create(:uploader_spec_image, assetable: @assetable)
        @image.original_name.should == 'А и б.png'
      end
    end

    describe 'build custom image name' do
      after do
        UploaderSpecImage.stub_build_filename = nil
      end

      it 'include secure_token' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.store_model_filename(@assetable)
        File.basename(@image.data.url).should == 'custom_filename_abc.png'
        @image.data.file.exists?.should be_true
        File.basename(@image.class.find(@image.id).data.url).should == 'custom_filename_abc.png'
      end

      it 'include secure_token' do
        UploaderSpecImage.stub_build_filename = 'Тест . - + ='
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.store_model_filename(@assetable)
        File.basename(@image.data.url).should == 'test_-_abc.png'
      end

      it 'skip rename when have missing files' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        FileUtils.mv @image.data.path, @image.data.path.sub('abc.png', 'new_abc.png')
        @image.store_model_filename(@assetable).should be_false
        File.basename(@image.data.url).should == 'abc.png'
      end
    end

    describe '#rename!' do
      it 'rename file via move' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        File.basename(@image.data.url(:thumb)).should == 'thumb.png'
        new_name = @image.rename!
        @image.save!
        filename = File.basename(new_name, '.*')
        filename.should =~ /\d+/
        File.basename(@image.data.url(:thumb)).should == "#{filename}_thumb.png"
        File.basename(@image.class.find(@image.id).data.url(:thumb)).should == "#{filename}_thumb.png"
      end
    end

    describe '#recreate_versions!' do
      it 'keep custom filenames' do
        @image = create(:main_uploader_spec_image, assetable: @assetable, data_file_name: 'custom.png')
        File.basename(@image.data.url(:thumb)).should == 'custom_thumb.png'
      end
    end
  end

  describe 'validations' do
    before do
      @image = create(:main_uploader_spec_image, assetable: @assetable)
    end

    #it 'should not be valid without data' do
    #  pending 'asset data validations dont work on presence_of'
    #  @avatar.data = nil
    #  @avatar.should_not be_valid
    #end

    it 'not valid with not image content-type' do
      @image.data_content_type = 'unknown type'
      @image.should_not be_valid
    end

    # wget https://dl.dropbox.com/u/48737256/silicon_valley.jpg -P spec/factories/files
    it 'not valid with big size image', slow: true do
      @image = build(:avatar_big)
      @image.should_not be_valid
      @image.errors[:data].first.should =~ /слишком большой размер/
    end
  end


  describe 'create callbacks' do
    before do
      @image = create(:main_uploader_spec_image, id: 12345678, assetable: @assetable)
    end

    it 'content-type should be valid' do
      @image.data_content_type.should == 'image/png'
    end

    it 'file size should be valid' do
      @image.data_file_size.should be_between(6400, 6600)
    end

    it 'should be image' do
      @image.image?.should be_true
    end

    it 'data_file_name should be valid' do
      @image.data_file_name.should == 'abc.png'
    end

    it 'width and height should be valid' do
      if @image.has_dimensions?
        @image.width.should == 50
        @image.height.should == 64
      end
    end

    it 'urls should be valid' do
      @image.url.should == "/uploads/#{@image.class.to_s.underscore}/123/45678/abc.png"
      @image.thumb_url.should == "/uploads/#{@image.class.to_s.underscore}/123/45678/thumb.png"
      @image.data.default_url.should == '/assets/defaults/uploader_spec_image.png'
    end
  end


  describe 'cropping' do
    before do
      @image = create(:main_uploader_spec_image, assetable: @assetable)
    end

    describe 'cropper_geometry' do
      before do
        @image.cropper_geometry = '50,64,10,10'
      end

      it 'construct cropping geometry' do
        @image.cropper_geometry.should == %w(50 64 10 10)
        @image.cropper_geometry_changed?.should == true
      end

      it 'set image dimensions before process' do
        @image.width.should == 50
        @image.height.should == 64
        @image.data.dimensions.should == [50, 64]
      end

      it 'crop image by specific geometry on save' do
        @image.save
        @image.width.should == 40
        @image.height.should == 54
        @image.data.dimensions.should == [40, 54]
      end
    end

    describe '#crop!' do
      it 'change filename' do
        @image.crop!('50,64,10,10')

        @image.data.dimensions.should == [40, 54]
        @image.data_file_name.should =~ /\d{1,4}\.png/
        File.basename(@image.data.url(:thumb)).should =~ /\d{1,4}_thumb\.png/

        @image = @image.class.find(@image.id)
        @image.data.dimensions.should == [40, 54]
        @image.data_file_name.should =~ /\d{1,4}\.png/
        File.basename(@image.data.url(:thumb)).should =~ /\d{1,4}_thumb\.png/
      end
    end
  end


  describe 'rotation' do
    before do
      @image = create(:main_uploader_spec_image, assetable: @assetable)
    end

    describe 'rotate_degrees' do
      before(:each) do
        @image.rotate_degrees = '90'
      end

      it 'set property correctly' do
        @image.rotate_degrees.should == '90'
        @image.rotate_degrees_changed?.should == true
      end

      it 'set image dimensions before process' do
        @image.width.should == 50
        @image.height.should == 64
        @image.data.dimensions.should == [50, 64]
      end

      it 'rotate image by degrees on save' do
        @image.save
        @image.width.should == 64
        @image.height.should == 50
        @image.data.dimensions.should == [64, 50]
      end
    end

    describe '#rotate!' do
      it 'rotate image' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.data.dimensions.should == [50, 64]
        @image.rotate!
        @image.width.should == 64
        @image.height.should == 50
        @image.data.dimensions.should == [64, 50]
      end
    end
  end

end

