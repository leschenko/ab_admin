class Structure < ActiveRecord::Base
  include AbAdmin::Models::Structure

  attr_accessible :structure_type_id, :position_type_id, :parent_id, :title, :redirect_url, :is_visible,
                  :structure_type, :position_type, :slug, :parent

  has_one :picture, -> { where(is_main: true) }, as: :assetable, dependent: :destroy
  has_many :pictures, -> { where(is_main: false) }, as: :assetable, dependent: :destroy

  fileuploads :picture
  translates :title, :redirect_url
  attr_accessible *all_translated_attribute_names

  include AbAdmin::Concerns::AdminAddition
  extend FriendlyId
  friendly_id :title, use: :slugged

  default_scope -> { nested_set.includes(:translations) }

  def should_generate_new_friendly_id?
    slug.blank? && new_record?
  end
end
