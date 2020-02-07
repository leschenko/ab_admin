class CreateProductCatalogues < ActiveRecord::Migration[5.2]
  def change
    create_table :product_catalogues do |t|
      t.references :product
      t.references :catalogue

      t.timestamps
    end
  end
end
