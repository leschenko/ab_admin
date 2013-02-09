class CreateHeaders < ActiveRecord::Migration
  def self.up
    create_table :headers do |t|
      t.string    :headerable_type, :limit => 30, :null => false
      t.integer   :headerable_id, :null => false
      
      t.timestamps
    end
    
    add_index :headers, [:headerable_type, :headerable_id], :unique => true
  end

  def self.down
    drop_table :headers
  end
end