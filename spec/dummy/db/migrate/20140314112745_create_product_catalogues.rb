class CreateProductCatalogues < ActiveRecord::Migration
  def change
    create_table :product_catalogues do |t|
      t.references :product, index: true
      t.references :catalogue, index: true

      t.timestamps
    end
  end
end
