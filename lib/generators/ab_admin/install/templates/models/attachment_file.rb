class AttachmentFile < Asset
  include AbAdmin::Models::AttachmentFile

  sunrise_uploader AttachmentFileUploader
  validates_filesize_of :data, :maximum => 150.megabytes

  self.max_size = 150
end
