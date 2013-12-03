require 'spec_helper'

class UploaderSpecImageUploader < AbAdmin::CarrierWave::BaseUploader
  version :thumb do
    process resize_to_fill: [80, 80]
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

  def build_filename(_)
    stub_build_filename || 'custom_filename'
  end
end

class UploaderSpecModel < RspecActiveModelBase
end


describe AbAdmin::CarrierWave::BaseUploader do
  context 'with models' do
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


    describe 'original filename' do
      it 'stored in original_name field' do
        @image = create(:uploader_spec_image, assetable: @assetable)
        @image.original_name.should == 'А и б.png'
      end
    end

    describe 'full image name' do
      it 'include secure_token' do
        @image = create(:uploader_spec_image, assetable: @assetable)
        File.basename(@image.data.url).should == 'abc.png'
        File.basename(@image.reload.data.url).should == 'abc.png'
      end
    end

    describe 'build custom image name' do
      after do
        UploaderSpecImage.stub_build_filename = nil
      end

      it 'include secure_token' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.store_model_filename
        File.basename(@image.data.url).should == 'custom_filename_abc.png'
        @image.data.file.exists?.should be_true
        File.basename(@image.class.find(@image.id).data.url).should == 'custom_filename_abc.png'
      end

      it 'include secure_token' do
        UploaderSpecImage.stub_build_filename = 'Тест . - + ='
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        @image.store_model_filename
        File.basename(@image.data.url).should == 'test_-_abc.png'
      end
    end

  end
end
