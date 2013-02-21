class AvatarUploader < AbAdmin::CarrierWave::BaseUploader
  
  process quality: 90
  
  version :thumb do
    process resize_to_fill: [80, 80, 'North']
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  #def move_to_cache
  #  true
  #end
end
