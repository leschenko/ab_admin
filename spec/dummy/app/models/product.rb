class Product < ActiveRecord::Base
  attr_accessible :is_visible, :price, :sku, :collection_id
  attr_accessible :name, :description, :name_en, :description_en, :name_ru, :description_ru

  belongs_to :collection

  has_one :picture, :as => :assetable, :dependent => :destroy, :conditions => {:is_main => true}
  has_many :pictures, :as => :assetable, :dependent => :destroy, :conditions => {:is_main => false}

  fileuploads :picture, :pictures
  translates :name, :description

  scope :visible, where(:is_visible => true)
  scope :un_visible, where(:is_visible => false)

  include AbAdmin::Concerns::AdminAddition

  alias_attribute :title, :name

end
