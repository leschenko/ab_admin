class CreateTranslationsCollectionProduct < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_translations do |t|
      t.references :collection, null: false
      t.string :locale, limit: 5, null: false
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :collection_translations, [:collection_id, :locale], unique: true, name: 'collections_ts_collection_id_locale'
    create_table :product_translations do |t|
      t.references :product, null: false
      t.string :locale, limit: 5, null: false
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :product_translations, [:product_id, :locale], unique: true, name: 'products_ts_product_id_locale'
  end
end
