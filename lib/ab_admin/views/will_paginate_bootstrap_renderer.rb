# Extracted from `will_paginate-bootstrap` (v0.2.5 written by Nicholas Dainty) because of some deprecated staff
require "will_paginate/view_helpers/action_view"
module AbAdmin
  module Views
    class WillPaginateBootstrapRenderer < WillPaginate::ActionView::LinkRenderer
      # Contains functionality shared by all renderer classes.
      ELLIPSIS = "&hellip;"

      def to_html
        list_items = pagination.map do |item|
          case item
          when Integer
            page_number(item)
          else
            send(item)
          end
        end.join(@options[:link_separator])

        if @options[:bootstrap].to_i >= 3
          tag("ul", list_items, class: "pagination")
        else
          html_container(tag("ul", list_items))
        end
      end

      def container_attributes
        super.except(*[:link_options])
      end

      protected

      def page_number(page)
        link_options = @options[:link_options] || {}
        if page == current_page
          tag("li", tag("span", page), class: "active")
        else
          tag("li", link(page, page, link_options.merge(rel: rel_value(page))))
        end
      end

      def gap
        tag("li", link(ELLIPSIS, "#"), class: "disabled")
      end

      def previous_page
        num = @collection.current_page > 1 && @collection.current_page - 1
        previous_or_next_page(num, @options[:previous_label], "prev")
      end

      def next_page
        num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
        previous_or_next_page(num, @options[:next_label], "next")
      end

      def previous_or_next_page(page, text, classname)
        link_options = @options[:link_options] || {}
        if page
          tag("li", link(text, page, link_options), class: classname)
        else
          tag("li", tag("span", text), class: "%s disabled" % classname)
        end
      end
    end
  end
end
