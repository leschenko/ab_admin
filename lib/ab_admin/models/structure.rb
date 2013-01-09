# -*- encoding : utf-8 -*-
module AbAdmin
  module Models
    module Structure
      extend ActiveSupport::Concern

      included do
        include AbAdmin::Models::Headerable

        enumerated_attribute :structure_type, :id_attribute => :kind
        enumerated_attribute :position_type, :id_attribute => :position

        validates_presence_of :title
        validates_numericality_of :position, :only_integer => true

        has_one :static_page, :dependent => :destroy

        acts_as_nested_set

        scope :visible, where(:is_visible => true)
        scope :with_kind, proc {|structure_type| where(:kind => structure_type.id) }
        scope :with_depth, proc {|level| where(:depth => level.to_i) }
        scope :with_position, proc {|position_type| where(:position => position_type.id).order('lft DESC') }
      end
      
      def moveable?
        new_record? or !root?
      end
    end
  end
end
