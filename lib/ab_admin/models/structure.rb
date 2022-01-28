module AbAdmin
  module Models
    module Structure
      extend ActiveSupport::Concern

      included do
        include AbAdmin::Concerns::Headerable
        include AbAdmin::Concerns::NestedSet
        extend EnumField::EnumeratedAttribute

        enumerated_attribute :structure_type
        enumerated_attribute :position_type

        validates_numericality_of :position_type_id, only_integer: true
        validates_numericality_of :structure_type_id, only_integer: true

        has_one :static_page, dependent: :destroy
        has_many :visible_children, -> { where(is_visible: true) }, class_name: name, foreign_key: :parent_id

        scope :visible, lambda { where(is_visible: true) }
        scope :with_type, lambda { |type| where(structure_type_id: (type.is_a?(Symbol) ? StructureType.public_send(type) : type.id)) }
        scope :with_depth, lambda { |level| where(depth: level.to_i) }
        scope :with_position, lambda { |type| where(position_type_id: (type.is_a?(Symbol) ? StructureType.public_send(type) : type.id)).order(lft: :desc) }
      end

      def redirect?
        structure_type_id == StructureType.redirect.id
      end

      def admin_title
        [title, structure_type.title, position_type.title, "#{self.class.han(:is_visible)}: #{is_visible ? '+' : '-'}"].join(' | ')
      end
    end
  end
end
