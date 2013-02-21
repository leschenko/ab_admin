class CreateStructures < ActiveRecord::Migration
  def self.up
    create_table :structures do |t|
      t.string :slug, null: false
      t.integer :kind, limit: 1, default: 1
      t.integer :position, limit: 2, default: 1
      t.references :user
      t.boolean :is_visible, default: true, null: false

      t.integer :parent_id
      t.integer :lft, default: 0
      t.integer :rgt, default: 0
      t.integer :depth, default: 0

      t.timestamps
    end

    add_index :structures, :user_id
    add_index :structures, [:slug, :kind], unique: true
    add_index :structures, :parent_id
    add_index :structures, [:lft, :rgt]
  end

  def self.down
    drop_table :structures
  end
end