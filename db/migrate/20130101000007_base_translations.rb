class BaseTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :static_page_translations do |t|
      t.references :static_page, null: false
      t.string :locale, limit: 5, null: false
      t.string :title
      t.text :content

      t.timestamps
    end
    add_index :static_page_translations, [:static_page_id, :locale], unique: true, name: 'static_pages_ts_static_page_id_locale'

    create_table :header_translations do |t|
      t.references :header, null: false
      t.string :locale, limit: 5, null: false
      t.string :title
      t.string :h1
      t.string :keywords
      t.text :description
      t.text :seo_block

      t.timestamps
    end
    add_index :header_translations, [:header_id, :locale], unique: true, name: 'headers_ts_header_id_locale'

    create_table :structure_translations do |t|
      t.references :structure, null: false
      t.string :locale, limit: 5, null: false
      t.string :title
      t.string :redirect_url

      t.timestamps
    end
    add_index :structure_translations, [:structure_id, :locale], unique: true, name: 'structures_ts_structure_id_locale'

    create_table :asset_translations do |t|
      t.references :asset, null: false
      t.string :locale, limit: 5, null: false
      t.string :name
      t.string :alt

      t.timestamps
    end
    add_index :asset_translations, [:asset_id, :locale], unique: true, name: 'assets_ts_asset_id_locale'
  end
end