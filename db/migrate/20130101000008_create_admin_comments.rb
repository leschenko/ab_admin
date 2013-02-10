class CreateAdminComments < ActiveRecord::Migration
  def change
    create_table :admin_comments do |t|
      t.integer :user_id
      t.integer :author_id, :null => false
      t.string :author_name
      t.integer :resource_id, :null => false
      t.string :resource_type, :limit => 30, :null => false
      t.text :body

      t.timestamps
    end

    add_index :admin_comments, :user_id
    add_index :admin_comments, :author_id
    add_index :admin_comments, [:resource_type, :resource_id]
  end
end
