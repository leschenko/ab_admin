# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module NestedSet
      extend ActiveSupport::Concern

      included do
        acts_as_nested_set
        after_move :update_search_index

        attr_accessor :cached_children

        scope :nested_set, order('lft ASC')
        scope :reversed_nested_set, order('lft DESC')
        scope :with_depth, proc { |level| where(:depth => level) }
      end

      module ClassMethods
        def build_tree(records)
          tree = {}
          roots = []
          records.each do |record|
            if record.root?
              roots << record
              next
            end
            tree[record.parent_id] ||= []
            tree[record.parent_id] << record
          end
          roots.each do |root|
            root.tree_children(tree)
          end
          roots
        end
      end

      def tree_children(tree)
        return unless tree[self.id]
        self.cached_children = tree[self.id]
        self.cached_children.each do |r|
          r.tree_children(tree)
        end
      end

      def self.nested_opts(records, mover=nil)
        res = []
        records.each do |r|
          next if mover && mover.id == r.id
          res << ["#{'–' * r.depth} #{r.name}", r.id]
        end
        res
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
