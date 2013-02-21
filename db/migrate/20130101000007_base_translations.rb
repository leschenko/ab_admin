class BaseTranslations < ActiveRecord::Migration
  def self.up
    StaticPage.create_translation_table! title: :string, content: :text
    Header.create_translation_table! title: :string, keywords: :string, description: :text
    Structure.create_translation_table! title: :string, redirect_url: :string
  end

  def self.down
    StaticPage.drop_translation_table!
    Header.drop_translation_table!
    Structure.drop_translation_table!
  end
end