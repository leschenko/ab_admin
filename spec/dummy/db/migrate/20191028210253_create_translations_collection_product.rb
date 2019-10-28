class CreateTranslationsCollectionProduct < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_translations do |t|
      t.references :collection, index: true
      t.string :locale, limit: 5
      t.string :name
      t.text :description

      t.timestamps
    end
    create_table :product_translations do |t|
      t.references :product, index: true
      t.string :locale, limit: 5
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
