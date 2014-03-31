module AbAdmin
  module Models
    module Header
      extend ActiveSupport::Concern

      included do
        include ActionView::Helpers::SanitizeHelper

        belongs_to :headerable, polymorphic: true
        before_save :normalize_html
      end
      
      def empty?
        [keywords, description, title].map(&:blank?).all?
      end

      def has_info?
        !empty?
      end

      def read(key)
        value = read_attribute(key)
        value.blank? ? nil : value
      end

      def normalize_html
        ::I18n.available_locales.each do |loc|
          %w(title h1 keywords description).each do |attr|
            send("#{attr}_#{loc}=", send("#{attr}_#{loc}").to_s.no_html)
          end
        end
        ::I18n.available_locales.each do |loc|
          send("seo_block_#{loc}=", sanitize(send("seo_block_#{loc}").to_s))
        end
      end

    end
  end
end
