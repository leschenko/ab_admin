class CreateCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :collections do |t|
      t.boolean :is_visible, default: true, null: false
      t.integer :products_count, default: 0

      t.timestamps
    end
  end
end
