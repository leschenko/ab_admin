class Structure < ApplicationRecord
  include AbAdmin::Models::Structure

  has_one :picture, -> { where(is_main: true) }, as: :assetable, dependent: :destroy
  has_many :pictures, -> { where(is_main: false) }, as: :assetable, dependent: :destroy

  fileuploads :picture
  translates :title, :redirect_url

  include AbAdmin::Concerns::AdminAddition
  simple_slug :title

  default_scope -> { nested_set.includes(:translations) }

  def should_generate_new_slug?
    slug.blank? && new_record?
  end
end
