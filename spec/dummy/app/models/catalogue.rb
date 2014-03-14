class Catalogue < ActiveRecord::Base
  attr_accessible :name, :parent

  has_many :product_catalogues, dependent: :destroy
  has_many :products, through: :product_catalogues
  has_many :visible_products, -> { where(is_visible: true) }, source: :product, through: :product_catalogues

  include AbAdmin::Concerns::NestedSet
  include AbAdmin::Concerns::AdminAddition

  default_scope -> { nested_set }

end
