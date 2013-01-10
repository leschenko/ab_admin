require 'spec_helper'
require 'carrierwave/test/matchers'

describe PictureUploader do
  include CarrierWave::Test::Matchers
  
  before do
    PictureUploader.enable_processing = true
    @avatar = FactoryGirl.build(:asset_avatar, :data => nil)
    @uploader = PictureUploader.new(@avatar, :data)
    @uploader.store!(File.open('spec/factories/files/rails.png'))
  end

  after do
    PictureUploader.enable_processing = false
  end
  
  context 'the thumb version' do
    it "should scale down a landscape image to be exactly 100 by 100 pixels" do
      @uploader.thumb.should have_dimensions(100, 100)
    end
  end
  
  context 'manipulation' do
    it "should strip image" do
      lambda {
        @uploader.strip
      }.should_not raise_error
    end
    
    it "should set image quality" do
      lambda {
        @uploader.quality(80)
      }.should_not raise_error
    end
    
    it "should rotate image" do
      lambda {
        @uploader.rotate(90)
      }.should_not raise_error
    end
    
    it "should crop image" do
      lambda {
        @uploader.cropper(["50x60", "+5+5"])
      }.should_not raise_error
    end
  end
end
