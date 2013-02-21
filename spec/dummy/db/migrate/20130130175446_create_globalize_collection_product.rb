class CreateGlobalizeCollectionProduct < ActiveRecord::Migration
  def up
    Collection.create_translation_table! name: :string, description: :text
    Product.create_translation_table! name: :string, description: :text
  end

  def down
    Collection.drop_translation_table!
    Product.drop_translation_table!
  end
end
