class Asset < ActiveRecord::Base
  include AbAdmin::Models::Asset

  attr_accessible :data, :is_main, :original_name, :base_filename
  translates :name, :alt
  attr_accessible *all_translated_attribute_names

  validates_presence_of :data
	
	default_scope -> { order("#{quoted_table_name}.sort_order") }

end
