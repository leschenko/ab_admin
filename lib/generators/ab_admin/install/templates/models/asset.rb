class Asset < ActiveRecord::Base
  include AbAdmin::Models::Asset

  attr_accessible :data, :is_main, :original_name

  validates_presence_of :data
	
	default_scope order("#{quoted_table_name}.sort_order")

end
