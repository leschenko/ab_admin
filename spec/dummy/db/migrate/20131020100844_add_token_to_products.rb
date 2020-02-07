class AddTokenToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :token, :string
    add_index :products, :token
  end
end
