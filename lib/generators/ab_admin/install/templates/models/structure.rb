# -*- encoding : utf-8 -*-
class Structure < ActiveRecord::Base
  include AbAdmin::Models::Structure

  attr_accessible :kind, :position, :parent_id, :title, :redirect_url, :is_visible,
                  :structure_type, :position_type, :slug, :parent

  has_one :picture, :as => :assetable, :dependent => :destroy

  fileuploads :picture
  translates :title, :redirect_url

  include AbAdmin::Concerns::AdminAddition
  extend FriendlyId
  friendly_id :title, :use => :slugged

  #after_create proc { @move_to_end = true }
  #after_save :move_to_end

  default_scope nested_set.includes(:translations)
  #default_scope reversed_nested_set.includes(:translations)

  alias_attribute :name, :title

  self.per_page = 1000

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

  #def move_to_end
  #  return unless @move_to_end
  #  target = siblings.first
  #  move_to_left_of(target.id) if target
  #end

end

# == Schema Information
#
# Table name: structures
#
#  id          :integer          not null, primary key
#  slug        :string(50)       not null
#  kind        :integer          default(1)
#  position    :integer          default(1)
#  user_id     :integer
#  is_visible  :boolean          default(TRUE), not null
#  delta       :boolean          default(TRUE), not null
#  parent_id   :integer
#  lft         :integer          default(0)
#  rgt         :integer          default(0)
#  depth       :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  import_id   :integer
#  linked_id   :integer
#  linked_type :string(50)
#  is_hidden   :boolean          default(FALSE), not null
#

