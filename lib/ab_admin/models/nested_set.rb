# -*- encoding : utf-8 -*-
module AbAdmin
  module Models
    module NestedSet
      extend ActiveSupport::Concern

      module ClassMethods
        def self.extended(base)
          base.class_eval do
            acts_as_nested_set
            after_move :update_search_index

            scope :with_kind, proc {|structure_type| where(:kind => structure_type.id) }
            scope :with_depth, proc {|level| where(:depth => level) }
            scope :with_position, proc {|position_type| where(:position => position_type.id) }
          end
        end
      end

      def deep_parent
        root? ? self : self.parent.try(:deep_parent)
      end

      def update_search_index
        tire.update_index if respond_to?(:tire)
        true
      end
    end
  end
end
