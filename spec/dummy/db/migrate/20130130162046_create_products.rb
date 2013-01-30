class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :collection
      t.string :sku
      t.string :price, :default => 0
      t.boolean :is_visible, :default => true, :null => false

      t.timestamps
    end
    add_index :products, :collection_id
  end
end
