class Catalogue < ActiveRecord::Base
  attr_accessible :name, :parent

  include AbAdmin::Concerns::NestedSet
  include AbAdmin::Concerns::AdminAddition


  default_scope -> { nested_set }

end
