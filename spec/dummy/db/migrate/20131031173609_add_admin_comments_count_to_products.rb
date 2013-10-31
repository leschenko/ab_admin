class AddAdminCommentsCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :admin_comments_count, :integer, default: 0
  end
end
