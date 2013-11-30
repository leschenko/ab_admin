class Picture < Asset
  ab_admin_uploader PictureUploader

	validates :data_content_type, inclusion: {in: AbAdmin.image_types }
	validates_integrity_of :data
	validates_filesize_of :data, maximum: 2.megabytes
end
