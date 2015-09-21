class AddIsDeletedToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_deleted, :boolean, default: false, null: false
  end
end
