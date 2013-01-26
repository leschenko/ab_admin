# -*- encoding : utf-8 -*-
class AttachmentFile < Asset
  include AbAdmin::Models::AttachmentFile

  sunrise_uploader AttachmentFileUploader
  validates_filesize_of :data, :maximum => 150.megabytes
end

# == Schema Information
#
# Table name: assets
#
#  id                :integer          not null, primary key
#  data_file_name    :string(255)      not null
#  data_content_type :string(255)
#  data_file_size    :integer
#  assetable_id      :integer          not null
#  assetable_type    :string(25)       not null
#  type              :string(25)
#  guid              :string(10)
#  locale            :integer          default(0)
#  user_id           :integer
#  sort_order        :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_main           :boolean          default(FALSE), not null
#  footmarks_count   :integer          default(0)
#  original_name     :string(255)
#

