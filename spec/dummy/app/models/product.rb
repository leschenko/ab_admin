class Product < ApplicationRecord
  belongs_to :collection

  has_many :product_catalogues, dependent: :destroy
  has_many :catalogues, through: :product_catalogues

  has_one :picture, -> { where(is_main: true) }, as: :assetable, dependent: :destroy
  has_many :pictures, -> { where(is_main: false) }, as: :assetable, dependent: :destroy
  has_many :attachment_files, -> { where(is_main: false) }, as: :assetable, dependent: :destroy

  fileuploads :picture, :pictures, :attachment_files
  translates :name, :description

  scope :visible, -> { where(is_visible: true) }
  scope :un_visible, -> { where(is_visible: false) }

  include AbAdmin::Concerns::AdminAddition
  include AbAdmin::Concerns::HasTracking

  scope :admin, proc { includes(:translations, :picture) }

  # alias_attribute :title, :name

  validates :sku, presence: true

  #include AbAdmin::Concerns::HasTracking

  default_scope -> { where(is_deleted: false) }

  def self.un_publish_collection(collection)
    collection.update_all(is_visible: false)
  end

  def publish!
    update_column(:is_visible, true)
  end

  def un_publish!
    update_column(:is_visible, false)
  end

  def set_zoom(batch_params)
    update_column(:zoom, batch_params[:zoom])
  end

  def self.set_zoom_collection(collection, batch_params)
    collection.update_all(zoom: batch_params[:zoom])
  end
end
