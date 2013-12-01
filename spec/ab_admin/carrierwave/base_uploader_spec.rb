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

  def data_secure_token
    'abc'
  end

  def build_file_name(_)
    return unless is_main
    'custom_file_name'
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

    describe 'original filename' do
      it 'stored in original_name field' do
        @image = create(:uploader_spec_image, assetable: @assetable)
        @image.original_name.should == 'А и б.png'
      end
    end

    describe 'full image name' do
      it 'include secure_token' do
        @image = create(:uploader_spec_image, assetable: @assetable)
        File.basename(@image.data.url).should == 'a_i_b_abc.png'
        File.basename(@image.reload.data.url).should == 'a_i_b_abc.png'
      end

      it 'filename with special characters' do
        @image = create(:uploader_spec_image, :bad_filename, assetable: @assetable)
        File.basename(@image.data.url).should == 'n_._-_+_abc.png'
      end
    end

    describe 'build custom image name' do
      it 'include secure_token' do
        @image = create(:main_uploader_spec_image, assetable: @assetable)
        File.basename(@image.data.url).should == 'custom_file_name_abc.png'
        @image = @image.class.find(@image.id)
        File.basename(@image.reload.data.url).should == 'custom_file_name_abc.png'
      end
    end

  end
end
