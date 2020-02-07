class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :collection
      t.string :sku
      t.string :price, default: 0
      t.boolean :is_visible, default: true, null: false

      t.timestamps
    end
  end
end
