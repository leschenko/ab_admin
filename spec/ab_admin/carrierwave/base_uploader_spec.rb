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


RSpec.describe AbAdmin::CarrierWave::BaseUploader do
  before :all do
    UploaderSpecImageUploader.enable_processing = true
    @assetable = UploaderSpecModel.new(id: 1)
  end

  after :all do
    UploaderSpecImageUploader.enable_processing = false
  end

  around do |example|
    I18n.with_locale(:de) { example.run }
  end

  context 'naming' do
    describe 'file names' do
      before do
        @image = create(:uploader_spec_image, assetable: @assetable)
      end

      context 'full name' do
        it 'include secure_token' do
          expect(File.basename(@image.data.url)).to eq 'abc.png'
          expect(File.basename(@image.class.find(@image.id).data.url)).to eq 'abc.png'
        end
      end

      context 'version name' do
        it 'only version name' do
          expect(File.basename(@image.data.url(:thumb))).to eq 'thumb.png'
          expect(File.basename(@image.class.find(@image.id).data.url(:thumb))).to eq 'thumb.png'
        end
      end
    end

    describe '#store_dir' do
      it 'create subdirectories from id' do
        @image = create(:uploader_spec_image, id: 12345678, assetable: @assetable)
        expect(@image.data.store_dir).to eq 'uploads/uploader_spec_image/123/45678'
      end

      it 'create subdirectories from id 2' do
        @image = create(:uploader_spec_image, id: 1, assetable: @assetable)
        expect(@image.data.store_dir).to eq 'uploads/uploader_spec_image/000/1'
      end
    end

    describe 'store original filename' do
      it 'stored in original_name field' do
        @image = create(:uploader_spec_image, assetable: @assetable)
        expect(@image.original_name).to eq 'А_и_б.png'
      end
    end

    describe 'build custom image name' do
      after do
        UploaderSpecImage.stub_build_filename = nil
      end

      it 'include secure_token' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.store_model_filename(@assetable)
        expect(File.basename(@image.data.url)).to eq 'custom_filename_abc.png'
        expect(@image.data.file.exists?).to be_truthy
        expect(File.basename(@image.class.find(@image.id).data.url)).to eq 'custom_filename_abc.png'
      end

      it 'include secure_token' do
        UploaderSpecImage.stub_build_filename = 'Test . - + ='
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.store_model_filename(@assetable)
        expect(File.basename(@image.data.url)).to eq 'test__abc.png'
      end
    end

    describe '#rename!' do
      it 'rename file via move' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        expect(File.basename(@image.data.url(:thumb))).to eq 'thumb.png'
        new_name = @image.rename!
        @image.save!
        filename = File.basename(new_name, '.*')
        filename.should =~ /\d+/
        expect(File.basename(@image.data.url(:thumb))).to eq "#{filename}_thumb.png"
        expect(File.basename(@image.class.find(@image.id).data.url(:thumb))).to eq "#{filename}_thumb.png"
      end
    end

    describe '#recreate_versions!' do
      it 'keep custom filenames' do
        @image = create(:main_uploader_spec_image, assetable: @assetable, data_file_name: 'custom.png')
        expect(File.basename(@image.data.url(:thumb))).to eq 'custom_thumb.png'
      end
    end
  end

  describe 'validations' do
    before do
      @image = create(:main_uploader_spec_image, assetable: @assetable)
    end

    it 'not valid with not image content-type' do
      @image.data_content_type = 'unknown type'
      expect(@image).not_to be_valid
    end

    # wget https://dl.dropbox.com/u/48737256/silicon_valley.jpg -P spec/factories/files
    it 'not valid with big size image', slow: true do
      @image = build(:avatar_big)
      expect(@image).not_to be_valid
      @image.errors[:data].first.should =~ /слишком большой размер/
    end
  end


  describe 'create callbacks' do
    before do
      @image = create(:main_uploader_spec_image, id: 12345678, assetable: @assetable)
    end

    it 'content-type should be valid' do
      expect(@image.data_content_type).to eq 'image/png'
    end

    it 'file size should be valid' do
      expect(@image.data_file_size).to be_between(6400, 6600)
    end

    it 'should be image' do
      expect(@image.image?).to be_truthy
    end

    it 'data_file_name should be valid' do
      expect(@image.data_file_name).to eq 'abc.png'
    end

    it 'width and height should be valid' do
      if @image.has_dimensions?
        expect(@image.width).to eq 50
        expect(@image.height).to eq 64
      end
    end

    it 'urls should be valid' do
      expect(@image.url).to eq "/uploads/#{@image.class.to_s.underscore}/123/45678/abc.png"
      expect(@image.thumb_url).to eq "/uploads/#{@image.class.to_s.underscore}/123/45678/thumb.png"
      expect(@image.data.default_url).to eq '/assets/defaults/uploader_spec_image.png'
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
        expect(@image.cropper_geometry).to eq %w(50 64 10 10)
        expect(@image.cropper_geometry_changed?).to eq true
      end

      it 'set image dimensions before process' do
        expect(@image.width).to eq 50
        expect(@image.height).to eq 64
        expect(@image.data.dimensions).to eq [50, 64]
      end

      it 'crop image by specific geometry on save' do
        @image.save
        expect(@image.width).to eq 40
        expect(@image.height).to eq 54
        expect(@image.data.dimensions).to eq [40, 54]
      end
    end

    describe '#crop!' do
      it 'change filename' do
        @image.crop!('50,64,10,10')

        expect(@image.data.dimensions).to eq [40, 54]
        @image.data_file_name.should =~ /\d{1,4}\.png/
        File.basename(@image.data.url(:thumb)).should =~ /\d{1,4}_thumb\.png/

        @image = @image.class.find(@image.id)
        expect(@image.data.dimensions).to eq [40, 54]
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
        expect(@image.rotate_degrees).to eq '90'
        expect(@image.rotate_degrees_changed?).to eq true
      end

      it 'set image dimensions before process' do
        expect(@image.width).to eq 50
        expect(@image.height).to eq 64
        expect(@image.data.dimensions).to eq [50, 64]
      end

      it 'rotate image by degrees on save' do
        @image.save
        expect(@image.width).to eq 64
        expect(@image.height).to eq 50
        expect(@image.data.dimensions).to eq [64, 50]
      end
    end

    describe '#rotate!' do
      it 'rotate image' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        expect(@image.data.dimensions).to eq [50, 64]
        @image.rotate!
        expect(@image.width).to eq 64
        expect(@image.height).to eq 50
        expect(@image.data.dimensions).to eq [64, 50]
      end
    end
  end
end

