class AddVisibleProductsCountToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :visible_products_count, :integer, default: 0
  end
end
