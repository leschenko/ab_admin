class AddIsDeletedToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :is_deleted, :boolean, default: false, null: false
  end
end
