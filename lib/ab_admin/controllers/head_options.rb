# -*- encoding : utf-8 -*-
module AbAdmin
  module Controllers
    module HeadOptions

      def head_options(record, options = {})
        return if record.nil?
        
        options = { splitter: AbAdmin.title_splitter, append_title: true }.merge(options)

        header = options[:header] || (record.respond_to?(:header) ? record.header : nil)

        if header && header.has_info?
          @page_keywords ||= header.read(:keywords)
          @page_description ||= header.read(:description)
          @page_title ||= header.read(:title)
        end

        @page_title ||= begin
          view_title = AbAdmin.display_name(record)

          page_title = []
	        page_title << options[:title] if options.key?(:title)
          page_title << view_title
          page_title << I18n.t('page.title') if options[:append_title]

          page_title.flatten.compact.uniq.join(options[:splitter])
        end
        @page_title = [I18n.t('page.page_title', page: options[:page]), @page_title].join(options[:splitter]) if options[:page]
        @page_description = [I18n.t('page.prefix'), @page_description].compact.join(' - ')
      end

    end
  end
end
