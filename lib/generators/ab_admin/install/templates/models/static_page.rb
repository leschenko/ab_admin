class StaticPage < ApplicationRecord
  belongs_to :structure

  has_many :pictures, as: :assetable, dependent: :destroy
  has_many :attachment_files, as: :assetable, dependent: :destroy, autosave: true

  validates_presence_of :title, :content

  enumerated_attribute :static_page_type, id_attribute: :kind

  fileuploads :pictures, :attachment_files
  translates :title, :content

end
