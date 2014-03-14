class AddProductsCountAndVisibleProductsCountToCatalogues < ActiveRecord::Migration
  def change
    add_column :catalogues, :products_count, :integer, default: 0
    add_column :catalogues, :visible_products_count, :integer, default: 0
  end
end
