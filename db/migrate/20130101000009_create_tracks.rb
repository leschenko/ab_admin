class CreateTracks < ActiveRecord::Migration[5.2]
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :key
      t.references :trackable, polymorphic: true
      t.references :user
      t.references :owner
      t.column :trackable_changes, :mediumtext
      t.text :parameters

      t.timestamps
    end
    add_index :tracks, :key
  end
end
