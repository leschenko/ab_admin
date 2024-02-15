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


RSpec.describe AbAdmin::CarrierWave::BaseUploader do
  before :all do
    UploaderSpecImageUploader.enable_processing = true
    @assetable = create(:catalogue)
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
          expect(File.basename(@image.data.url)).to eq 'juer_gen_abc.png'
          expect(File.basename(@image.class.find(@image.id).data.url)).to eq 'juer_gen_abc.png'
        end
      end

      context 'version name' do
        it 'only version name' do
          expect(File.basename(@image.data.url(:thumb))).to eq 'juer_gen_thumb.png'
          expect(File.basename(@image.class.find(@image.id).data.url(:thumb))).to eq 'juer_gen_thumb.png'
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
        expect(@image.original_name).to eq 'Jür_gen.png'
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
        expect(File.basename(@image.data.url)).to eq 'test_abc.png'
      end
    end

    describe '#rename!' do
      it 'rename file via move' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        expect(File.basename(@image.data.url(:thumb))).to eq 'juer_gen_thumb.png'
        @image.rename!
        @image.save!
        expect(File.basename(@image.url, '.*')).to match /\d+/
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
      expect(@image.errors[:data].first).to match /is too big/
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
      expect(@image.data_file_size).to be_between(6500, 6700)
    end

    it 'should be image' do
      expect(@image.image?).to be_truthy
    end

    it 'data_file_name should be valid' do
      expect(@image.data_file_name).to eq 'juer_gen_abc.png'
    end

    it 'width and height should be valid' do
      if @image.has_dimensions?
        expect(@image.width).to eq 50
        expect(@image.height).to eq 64
      end
    end

    it 'urls should be valid' do
      expect(@image.url).to eq "/uploads/#{@image.class.to_s.underscore}/123/45678/juer_gen_abc.png"
      expect(@image.thumb_url).to eq "/uploads/#{@image.class.to_s.underscore}/123/45678/juer_gen_thumb.png"
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
        expect(@image.width).to eq 50
        expect(@image.height).to eq 64
        expect(@image.data.dimensions).to eq [50, 64]
      end
    end

    describe '#crop!' do
      it 'change filename' do
        @image.crop!('50,64,10,10')

        expect(@image.data.dimensions).to eq [50, 64]

        @image = @image.class.find(@image.id)
        expect(@image.data.dimensions).to eq [50, 64]
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

  describe 'webp' do
    describe '#options_for_webp' do
      before :all do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
      end

      context 'resize_to_fill' do
        it 'return options for crop y' do
          allow(@image.data).to receive(:width).and_return(50)
          allow(@image.data).to receive(:height).and_return(64)
          expect(@image.data.options_for_webp(resize_to_fill: [10, 10])).to eq({crop_h: 50, crop_w: 50, crop_x: 0, crop_y: 7, resize_h: 10, resize_w: 10})
        end

        it 'return options for crop x' do
          allow(@image.data).to receive(:width).and_return(64)
          allow(@image.data).to receive(:height).and_return(50)
          expect(@image.data.options_for_webp(resize_to_fill: [10, 10])).to eq({crop_h: 50, crop_w: 50, crop_x: 7, crop_y: 0, resize_h: 10, resize_w: 10})
        end

        it 'omit crop options if not needed' do
          allow(@image.data).to receive(:width).and_return(50)
          allow(@image.data).to receive(:height).and_return(50)
          expect(@image.data.options_for_webp(resize_to_fill: [10, 10])).to eq({resize_h: 10, resize_w: 10})
        end

        it 'omit crop and resize options if not needed' do
          allow(@image.data).to receive(:width).and_return(10)
          allow(@image.data).to receive(:height).and_return(10)
          expect(@image.data.options_for_webp(resize_to_fill: [10, 10])).to be_blank
        end
      end

      context 'resize_to_fit' do
        it 'return options for resize y' do
          allow(@image.data).to receive(:width).and_return(50)
          allow(@image.data).to receive(:height).and_return(64)
          expect(@image.data.options_for_webp(resize_to_fit: [10, 10])).to eq({resize_h: 10})
        end

        it 'return options for resize x' do
          allow(@image.data).to receive(:width).and_return(64)
          allow(@image.data).to receive(:height).and_return(50)
          expect(@image.data.options_for_webp(resize_to_fit: [10, 10])).to eq({resize_w: 10})
        end

        it 'return options for resize x and y' do
          allow(@image.data).to receive(:width).and_return(50)
          allow(@image.data).to receive(:height).and_return(50)
          expect(@image.data.options_for_webp(resize_to_fit: [10, 10])).to eq({resize_h: 10, resize_w: 10})
        end

        it 'omit resize options if not needed' do
          allow(@image.data).to receive(:width).and_return(10)
          allow(@image.data).to receive(:height).and_return(10)
          expect(@image.data.options_for_webp(resize_to_fit: [10, 10])).to be_blank
        end
      end
    end
  end
end

