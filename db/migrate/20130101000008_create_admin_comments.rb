class CreateAdminComments < ActiveRecord::Migration
  def change
    create_table :admin_comments do |t|
      t.references :user
      t.string :user_name
      t.integer :resource_id, null: false
      t.string :resource_type, limit: 50, null: false
      t.references :resource_user
      t.text :body

      t.timestamps
    end

    add_index :admin_comments, :user_id
    add_index :admin_comments, :resource_user_id
    add_index :admin_comments, [:resource_type, :resource_id]
  end
end
