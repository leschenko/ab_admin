# -*- encoding : utf-8 -*-
class StaticPage < ActiveRecord::Base
  attr_accessible :structure_id, :title, :content, :kind, :is_visible

  belongs_to :structure

  has_many :pictures, :as => :assetable, :dependent => :destroy
  has_many :attachment_files, :as => :assetable, :dependent => :destroy, :autosave => true

  validates_presence_of :title, :content

  enumerated_attribute :static_page_type, :id_attribute => :kind

  translates :title, :content

end

# == Schema Information
#
# Table name: static_pages
#
#  id           :integer          not null, primary key
#  structure_id :integer          not null
#  user_id      :integer
#  is_visible   :boolean          default(TRUE), not null
#  delta        :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  import_id    :integer
#

