class AddInStockAtToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :in_stock_at, :datetime
  end
end
