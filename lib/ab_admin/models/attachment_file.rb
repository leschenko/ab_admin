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
        I18n.l(created_at, :format => '%d %B %Y')
      end

      def as_json(options={})
        options.reverse_merge!(:methods => [:filename, :url, :preview_url, :thumb_url, :width, :height,
                                            :file_css_class, :human_filesize, :created_at])
        super
      end
    end
  end
end
