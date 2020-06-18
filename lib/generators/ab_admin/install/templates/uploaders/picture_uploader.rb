class PictureUploader < AbAdmin::CarrierWave::BaseUploader
  
  # process quality: 80
  # process cropper: :cropper_geometry

  version :thumb do
    process resize_to_fill: [80, 80]
  end

  version :content do
    process quality: 80
    process resize_to_fill: [800, 800]
  end

  version :content_webp do
    process convert_to_webp: [{quality: 90, method: 5, resize_to_fill: [800, 800]}]
  end

  # version :content_webp do
  #   process convert_to_webp: [{quality: 80, method: 5, resize_w: 800, resize_h: 800}]
  # end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
