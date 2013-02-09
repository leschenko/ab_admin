class Header < ActiveRecord::Base

  attr_accessible :title, :keywords, :description

  translates :title, :keywords, :description
  attr_accessible *all_translated_attribute_names

  include AbAdmin::Models::Header

end
