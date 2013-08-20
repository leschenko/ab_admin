class CreateHeaders < ActiveRecord::Migration
  def change
    create_table :headers do |t|
      t.string    :headerable_type, limit: 50, null: false
      t.integer   :headerable_id, null: false
      
      t.timestamps
    end
    
    add_index :headers, [:headerable_type, :headerable_id], unique: true
  end
end