module WillPaginate
  module ActiveRecord
    module RelationMethods
      attr_accessor :paginate_limit, :paginate_offset, :paginate_ids

      def per_page(value = nil)
        if value.nil?
          paginate_limit || limit_value
        else
          limit(value)
        end
      end

      def offset(value = nil)
        if value.nil?
          paginate_offset || offset_value
        else
          super(value)
        end
      end
    end

    module Pagination
      def paginate(options)
        options = options.dup
        pagenum = options.fetch(:page) { raise ArgumentError, ":page parameter required" }
        per_page = options.delete(:per_page) || self.per_page
        total = options.delete(:total_entries)
        large = options.delete(:large)

        count_options = options.delete(:count)
        options.delete(:page)

        rel = limit(per_page.to_i).page(pagenum)
        rel = rel.apply_finder_options(options) if options.any?
        rel.wp_count_options = count_options if count_options
        rel.total_entries = total.to_i unless total.blank?

        if large
          new_rel = rel.except(:limit, :offset, :where).where(:id => rel.pluck("#{quoted_table_name}.id"))
          new_rel.paginate_limit = rel.limit_value.to_i
          new_rel.paginate_offset = rel.offset_value.to_i
          new_rel.total_entries = rel.total_entries
          new_rel.current_page = rel.current_page
          new_rel
        else
          rel
        end
      end
    end
  end
end

WillPaginate::ActionView::LinkRenderer.class_exec do
  def url(page)
    @base_url_params ||= begin
      url_params = merge_get_params(default_url_params)
      merge_optional_params(url_params)
    end

    url_params = @base_url_params.dup
    add_current_page_param(url_params, page)

    link = @template.url_for(url_params)
    @options[:no_uri] ? link.split('?').first : link
  end
end
