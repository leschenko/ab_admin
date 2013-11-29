class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string  :data_file_name, null: false
      t.string  :data_content_type
      t.integer :data_file_size
      
      t.integer :assetable_id, null: false
		  t.string  :assetable_type, limit: 30, null: false
      t.string  :type, limit: 30
      t.string  :guid, limit: 10

      t.integer :locale, limit: 1, default: 0
      t.integer :user_id
      t.integer :sort_order, default: 0

      t.integer :width
      t.integer :height

      t.boolean :is_main, default: false, null: false
      t.string  :original_name
      t.string  :data_secure_token, limit: 20

      t.timestamps
    end
    
    add_index :assets, [:assetable_type, :type, :assetable_id]
    add_index :assets, :guid
    add_index :assets, :data_secure_token
    add_index :assets, :user_id
  end
end