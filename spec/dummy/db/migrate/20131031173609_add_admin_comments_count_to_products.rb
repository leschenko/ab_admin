class AddAdminCommentsCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :admin_comments_count, :integer, default: 0
  end
end
