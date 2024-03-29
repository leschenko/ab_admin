class Collection < ApplicationRecord
  has_many :products
  has_many :visible_products, -> { where(is_visible: true) }, class_name: 'Product'

  has_one :picture, -> { where(is_main: true) }, as: :assetable, dependent: :destroy
  has_many :pictures, -> { where(is_main: false) }, as: :assetable, dependent: :destroy
  has_many :attachment_files, as: :assetable, dependent: :destroy

  fileuploads :picture, :pictures, :attachment_files
  translates :name, :description

  scope :visible, -> { where(is_visible: true) }
  scope :un_visible, -> { where(is_visible: false) }

  accepts_nested_attributes_for :products, allow_destroy: true

  # alias_attribute :title, :name
end
