module AbAdmin
  module Concerns
    module NestedSet
      extend ActiveSupport::Concern

      included do
        acts_as_nested_set
        after_move :update_search_index

        attr_accessor :cached_children

        scope :nested_set, -> { order(:lft) }
        scope :reversed_nested_set, -> { order(lft: :desc) }
        scope :with_depth, lambda { |level| where(depth: level) }
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

        def nested_opts(records, item=nil)
          item = nil if item && !item.is_a?(self)
          res = []
          records.each do |r|
            next if item && item.id == r.id
            res << ["#{'–' * r.depth} #{AbAdmin.display_name(r)}", r.id]
          end
          res
        end

        def nested_opts_with_parent(records, item=nil)
          item = nil if item && !item.is_a?(self)
          res = []
          parents = []
          records.each do |r|
            r.root? ? parents = [] : parents.reject! { |p| p.depth >= r.depth }

            unless item && item.id == r.id
              res << ["#{parents.map { |c| "#{AbAdmin.display_name(c)} - " }.join} <b>#{AbAdmin.display_name(r)}</b>", r.id]
            end

            parents << r
          end
          res
        end
      end

      def nested_opts_with_parent(collection=nil)
        collection ||= self.class.all
        self.class.nested_opts_with_parent(collection, self)
      end

      def nested_opts(collection=nil)
        collection ||= self.class.all
        self.class.nested_opts(collection, self)
      end

      def tree_children(tree)
        return unless tree[self.id]
        self.cached_children = tree[self.id]
        self.cached_children.each do |r|
          r.tree_children(tree)
        end
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
