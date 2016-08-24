module AbAdmin
  module Controllers
    module HeadOptions

      def head_options(record, options = {})
        return if record.nil?
        
        options = { splitter: AbAdmin.title_splitter, append_title: true, desc_prefix: true }.merge(options)

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
          page_title << I18n.t('seo.title') if options[:append_title]

          page_title.flatten.compact.uniq.join(options[:splitter])
        end
        @page_title = "#{I18n.t('seo.page', page: options[:page])} #{@page_title}" if options[:page]
        description_parts = [@page_description, options[:desc_suffix]]
        description_parts.unshift(I18n.t('seo.prefix')) if options[:desc_prefix]
        @page_description = description_parts.compact.join(' - ')
      end

    end
  end
end
