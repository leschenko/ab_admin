class Collection < ActiveRecord::Base
  attr_accessible :is_visible, :products_count
  attr_accessible :name, :description, :name_en, :description_en, :name_ru, :description_ru

  has_many :products

  has_one :picture, :as => :assetable, :dependent => :destroy, :conditions => {:is_main => true}
  has_many :pictures, :as => :assetable, :dependent => :destroy, :conditions => {:is_main => false}
  has_many :attachment_files, :as => :assetable, :dependent => :destroy

  fileuploads :picture, :pictures, :attachment_files
  translates :name, :description

  scope :visible, where(:is_visible => true)
  scope :un_visible, where(:is_visible => false)

  alias_attribute :title, :name
end
