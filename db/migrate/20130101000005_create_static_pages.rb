class CreateStaticPages < ActiveRecord::Migration[5.2]
  def change
    create_table :static_pages do |t|
      t.references :structure, null: false
      t.references :user
      t.boolean :is_visible, default: true, null: false

      t.timestamps
    end
  end
end