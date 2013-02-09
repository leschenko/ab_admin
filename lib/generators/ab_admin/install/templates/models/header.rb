class Header < ActiveRecord::Base

  attr_accessible :title, :keywords, :description

  translates :title, :keywords, :description

  include AbAdmin::Models::Header

end
