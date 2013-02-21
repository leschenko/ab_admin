class CreateCatalogues < ActiveRecord::Migration
  def change
    create_table :catalogues do |t|
      t.string :name
      t.integer :parent_id
      t.integer :lft, default: 0
      t.integer :rgt, default: 0
      t.integer :depth, default: 0

      t.timestamps
    end

    add_index :catalogues, :parent_id
    add_index :catalogues, [:lft, :rgt]
  end
end
