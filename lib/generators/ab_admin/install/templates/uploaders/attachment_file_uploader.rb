# -*- encoding : utf-8 -*-
class AttachmentFileUploader < AbAdmin::CarrierWave::BaseUploader
  def extension_white_list
    %w(pdf doc docx xls xlsx ppt pptx zip rar csv pln pla dwg dwf 3ds dgn sat psd mat max ai prg fbx dae)
  end
end
