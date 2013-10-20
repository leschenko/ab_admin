class AddTokenToProducts < ActiveRecord::Migration
  def change
    add_column :products, :token, :string
    add_index :products, :token
  end
end
