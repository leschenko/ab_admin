class Avatar < Asset
  sunrise_uploader AvatarUploader  
  
	validates :data_content_type, inclusion: {in: AbAdmin.image_types }
	validates_integrity_of :data
	validates_filesize_of :data, maximum: 1.megabyte

end
