require 'will_paginate/active_record'

# add `:large` option with make pagination on large tables easier, because `SELECT *` is slow with large `OFFSET`:
#   first it fetch ids of the records using `SELECT id`
#   and in the second query it fetch records
module WillPaginate
  module ActiveRecord
    module RelationMethods
      attr_accessor :paginate_limit, :paginate_offset

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
        page_number = options.fetch(:page) { raise ArgumentError, ':page parameter required' }
        per_page = options.delete(:per_page) || self.per_page
        total = options.delete(:total_entries)
        large = options.delete(:large)

        count_options = options.delete(:count)
        options.delete(:page)

        rel = limit(per_page.to_i).page(page_number)
        rel = rel.apply_finder_options(options) if options.any?
        rel.wp_count_options = count_options if count_options
        rel.total_entries = total.to_i unless total.blank?

        if large
          ids = rel.except(:includes).pluck(Arel.sql("#{quoted_table_name}.#{primary_key}"))
          new_rel = rel.except(:limit, :offset, :where).where(primary_key => ids)
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