class Asset < ApplicationRecord
  include AbAdmin::Models::Asset

  translates :name, :alt

  validates_presence_of :data

  default_scope -> { order(:sort_order) }

end
