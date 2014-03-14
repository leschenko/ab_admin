class ProductCatalogue < ActiveRecord::Base
  belongs_to :product
  belongs_to :catalogue
end
