class AttachmentFileUploader < AbAdmin::CarrierWave::BaseUploader
  def extension_allowlist
    %w(pdf doc docx xls xlsx ppt pptx jpg jpeg gif png zip rar csv)
  end
end
