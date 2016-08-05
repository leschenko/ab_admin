class Collection < ActiveRecord::Base
  attr_accessible :is_visible, :products_count
  attr_accessible :name, :description, :name_en, :description_en, :name_ru, :description_ru, :products_attributes

  has_many :products
  has_many :visible_products, -> { where(is_visible: true) }, class_name: 'Product'

  has_one :picture, -> { where(is_main: true) }, as: :assetable, dependent: :destroy
  has_many :pictures, -> { where(is_main: false) }, as: :assetable, dependent: :destroy
  has_many :attachment_files, as: :assetable, dependent: :destroy

  fileuploads :picture, :pictures, :attachment_files
  translates :name, :description
  attr_accessible *all_translated_attribute_names

  scope :visible, -> { where(is_visible: true) }
  scope :un_visible, -> { where(is_visible: false) }

  accepts_nested_attributes_for :products, allow_destroy: true

  alias_attribute :title, :name
end
