class AddVisibleProductsCountToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :visible_products_count, :integer, default: 0
  end
end
