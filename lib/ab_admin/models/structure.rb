module AbAdmin
  module Models
    module Structure
      extend ActiveSupport::Concern

      included do
        include AbAdmin::Concerns::Headerable
        include AbAdmin::Concerns::NestedSet

        enumerated_attribute :structure_type, :id_attribute => :kind
        enumerated_attribute :position_type, :id_attribute => :position

        validates_presence_of :title
        validates_numericality_of :position, :only_integer => true

        has_one :static_page, :dependent => :destroy
        has_many :visible_children, :class_name => name, :foreign_key => 'parent_id', :conditions => {:is_visible => true}

        scope :visible, where(:is_visible => true)
        scope :with_kind, proc {|structure_type| where(:kind => structure_type.id) }
        scope :with_position, proc {|position_type| where(:position => position_type.id).order('lft DESC') }
      end

    end
  end
end
