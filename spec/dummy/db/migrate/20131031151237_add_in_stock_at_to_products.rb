class AddInStockAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :in_stock_at, :datetime
  end
end
