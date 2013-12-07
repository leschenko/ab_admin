class BaseTranslations < ActiveRecord::Migration
  def self.up
    StaticPage.create_translation_table! title: :string, content: :text
    Header.create_translation_table! title: :string, h1: :string, keywords: :string, description: :text, seo_block: :text
    Structure.create_translation_table! title: :string, redirect_url: :string
    Asset.create_translation_table! title: :string, alt: :string
  end

  def self.down
    StaticPage.drop_translation_table!
    Header.drop_translation_table!
    Structure.drop_translation_table!
    Asset.drop_translation_table!
  end
end