# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module NestedSet
      extend ActiveSupport::Concern

      included do
        acts_as_nested_set
        after_move :update_search_index

        scope :with_depth, proc { |level| where(:depth => level) }
      end

      def deep_parent
        root? ? self : self.parent.try(:deep_parent)
      end

      def moveable?
        new_record? || !root?
      end

      def descendants_count
        (right - left - 1) / 2
      end

      def update_search_index
        tire.update_index if respond_to?(:tire)
        true
      end
    end
  end
end
