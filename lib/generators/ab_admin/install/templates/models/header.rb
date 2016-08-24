class Header < ApplicationRecord

  attr_accessible :title, :keywords, :description, :h1, :seo_block

  translates :title, :keywords, :description, :h1, :seo_block, fallbacks_for_empty_translations: false
  attr_accessible *all_translated_attribute_names

  include AbAdmin::Models::Header

end
