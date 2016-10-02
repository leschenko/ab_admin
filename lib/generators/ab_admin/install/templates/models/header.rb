class Header < ApplicationRecord
  translates :title, :keywords, :description, :h1, :seo_block, fallbacks_for_empty_translations: false

  include AbAdmin::Models::Header

end
