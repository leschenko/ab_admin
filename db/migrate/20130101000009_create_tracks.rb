class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :key
      t.belongs_to :trackable, :polymorphic => true
      t.belongs_to :user, :polymorphic => true
      t.belongs_to :owner, :polymorphic => true
      t.column :changes, :mediumtext
      t.text :parameters

      t.timestamps
    end

    add_index :tracks, [:trackable_type, :trackable_id]
    add_index :tracks, [:owner_type, :owner_id]
    add_index :tracks, [:user_type, :user_id]
    add_index :tracks, :key
  end
end
