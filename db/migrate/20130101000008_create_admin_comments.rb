class CreateAdminComments < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_comments do |t|
      t.references :user
      t.string :user_name
      t.references :resource, polymorphic: true
      t.references :resource_user
      t.text :body

      t.timestamps
    end
  end
end
