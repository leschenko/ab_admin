# -*- encoding : utf-8 -*-
module AbAdmin
  module Models
    module AttachmentFile

      extend ActiveSupport::Concern

      included do
        include ActionView::Helpers::NumberHelper
      end

      def file_css_class
        MIME::Type.new(data_content_type).try(:sub_type).gsub('.', '_')
      end

      def human_name
        original_name.presence || data_file_name
      end

      def human_filesize
        number_to_human_size(data_file_size)
      end

      def human_date
        I18n.l(created_at, :format => "%d %B %Y")
      end

      def as_json(options={})
        options.reverse_merge!(:methods => [:filename, :url, :preview_url, :thumb_url, :width, :height,
                                            :file_css_class, :human_filesize, :created_at])
        super
      end
    end
  end
end

# == Schema Information
#
# Table name: assets
#
#  id                :integer(4)      not null, primary key
#  data_file_name    :string(255)     not null
#  data_content_type :string(255)
#  data_file_size    :integer(4)
#  assetable_id      :integer(4)      not null
#  assetable_type    :string(25)      not null
#  type              :string(25)
#  guid              :string(10)
#  locale            :integer(1)      default(0)
#  user_id           :integer(4)
#  sort_order        :integer(4)      default(0)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  is_main           :boolean(1)      default(FALSE), not null
#  footmarks_count   :integer(4)      default(0)
#  original_name     :string(255)
#

