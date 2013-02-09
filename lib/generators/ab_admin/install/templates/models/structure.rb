class Structure < ActiveRecord::Base
  include AbAdmin::Models::Structure

  self.per_page = 1000

  attr_accessible :kind, :position, :parent_id, :title, :redirect_url, :is_visible,
                  :structure_type, :position_type, :slug, :parent

  has_one :picture, :as => :assetable, :dependent => :destroy

  fileuploads :picture
  translates :title, :redirect_url

  include AbAdmin::Concerns::AdminAddition
  extend FriendlyId
  friendly_id :title, :use => :slugged

  default_scope nested_set.includes(:translations)

  def og_tags
    res = {
        'og:title' => title,
        'og:type' => 'activity',
        'og:description' => header.try(:description)
    }
    res['og:image'] = picture.full_url(:content) if picture
    res
  end

  def should_generate_new_friendly_id?
    slug.blank? && new_record?
  end

end
