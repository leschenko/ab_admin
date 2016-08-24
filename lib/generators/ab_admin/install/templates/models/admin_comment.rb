class AdminComment < ApplicationRecord
  include AbAdmin::Models::AdminComment

  attr_accessible :body, :resource_id, :resource_type
end