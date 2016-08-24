class Track < ApplicationRecord
  include AbAdmin::Models::Track

  attr_accessible :key, :name, :user, :owner, :trackable, :trackable_changes, :parameters
end
