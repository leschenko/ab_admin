class AttachmentFileUploader < AbAdmin::CarrierWave::BaseUploader
  def extension_whitelist
    %w(pdf doc docx xls xlsx ppt pptx jpg jpeg gif png zip rar csv)
  end
end
