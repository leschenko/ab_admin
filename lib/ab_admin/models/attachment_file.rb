module AbAdmin
  module Models
    module AttachmentFile

      extend ActiveSupport::Concern

      included do
        include ActionView::Helpers::NumberHelper
        alias_method :is_image, :image?
      end

      def file_css_class
        MIME::Type.new(data_content_type).try(:sub_type).gsub('.', '_')
      end

      def human_filesize
        number_to_human_size(data_file_size)
      end

      def human_date
        I18n.l(created_at, format: '%d %B %Y')
      end

      def as_json(options={})
        options.reverse_merge!(methods: [:filename, :url, :is_image, :file_css_class, :human_filesize, :created_at])
        super
      end
    end
  end
end
