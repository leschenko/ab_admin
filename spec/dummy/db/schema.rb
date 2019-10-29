# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_29_085351) do

  create_table "admin_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "user_name"
    t.integer "resource_id", null: false
    t.string "resource_type", limit: 50, null: false
    t.integer "resource_user_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["resource_type", "resource_id"], name: "index_admin_comments_on_resource_type_and_resource_id"
    t.index ["resource_user_id"], name: "index_admin_comments_on_resource_user_id"
    t.index ["user_id"], name: "index_admin_comments_on_user_id"
  end

  create_table "asset_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.string "locale", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.string "alt"
    t.index ["asset_id"], name: "index_asset_translations_on_asset_id"
    t.index ["locale"], name: "index_asset_translations_on_locale"
  end

  create_table "assets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.integer "assetable_id", null: false
    t.string "assetable_type", limit: 30, null: false
    t.string "type", limit: 30
    t.string "guid", limit: 10
    t.integer "locale", limit: 1, default: 0
    t.integer "user_id"
    t.integer "sort_order", default: 0
    t.integer "width"
    t.integer "height"
    t.boolean "is_main", default: false, null: false
    t.string "original_name"
    t.string "data_secure_token", limit: 20
    t.string "cached_alt"
    t.string "cached_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assetable_type", "type", "assetable_id"], name: "index_assets_on_assetable_type_and_type_and_assetable_id"
    t.index ["data_secure_token"], name: "index_assets_on_data_secure_token"
    t.index ["guid"], name: "index_assets_on_guid"
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "catalogues", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "lft", default: 0
    t.integer "rgt", default: 0
    t.integer "depth", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "products_count", default: 0
    t.integer "visible_products_count", default: 0
    t.index ["lft", "rgt"], name: "index_catalogues_on_lft_and_rgt"
    t.index ["parent_id"], name: "index_catalogues_on_parent_id"
  end

  create_table "ckeditor_assets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.integer "assetable_id"
    t.string "assetable_type", limit: 30
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"
  end

  create_table "collection_translations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.string "locale", limit: 5, null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "locale"], name: "collections_ts_collection_id_locale", unique: true
    t.index ["collection_id"], name: "index_collection_translations_on_collection_id"
  end

  create_table "collections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "is_visible", default: true, null: false
    t.integer "products_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "visible_products_count", default: 0
  end

  create_table "header_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "header_id", null: false
    t.string "locale", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.string "h1"
    t.string "keywords"
    t.text "description"
    t.text "seo_block"
    t.index ["header_id"], name: "index_header_translations_on_header_id"
    t.index ["locale"], name: "index_header_translations_on_locale"
  end

  create_table "headers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "headerable_type", limit: 50, null: false
    t.integer "headerable_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["headerable_type", "headerable_id"], name: "index_headers_on_headerable_type_and_headerable_id", unique: true
  end

  create_table "product_catalogues", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "product_id"
    t.integer "catalogue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["catalogue_id"], name: "index_product_catalogues_on_catalogue_id"
    t.index ["product_id"], name: "index_product_catalogues_on_product_id"
  end

  create_table "product_translations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "locale", limit: 5, null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "locale"], name: "products_ts_product_id_locale", unique: true
    t.index ["product_id"], name: "index_product_translations_on_product_id"
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "collection_id"
    t.string "sku"
    t.string "price", default: "0"
    t.boolean "is_visible", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "lat"
    t.float "lon"
    t.integer "zoom", default: 14
    t.string "token"
    t.datetime "in_stock_at"
    t.integer "admin_comments_count", default: 0
    t.boolean "is_deleted", default: false, null: false
    t.index ["collection_id"], name: "index_products_on_collection_id"
    t.index ["token"], name: "index_products_on_token"
  end

  create_table "static_page_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "static_page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.text "content"
    t.index ["locale"], name: "index_static_page_translations_on_locale"
    t.index ["static_page_id"], name: "index_static_page_translations_on_static_page_id"
  end

  create_table "static_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "structure_id", null: false
    t.integer "user_id"
    t.boolean "is_visible", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["structure_id"], name: "index_static_pages_on_structure_id"
    t.index ["user_id"], name: "index_static_pages_on_user_id"
  end

  create_table "structure_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "structure_id", null: false
    t.string "locale", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.string "redirect_url"
    t.index ["locale"], name: "index_structure_translations_on_locale"
    t.index ["structure_id"], name: "index_structure_translations_on_structure_id"
  end

  create_table "structures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "structure_type_id", limit: 1, default: 1
    t.integer "position_type_id", limit: 1, default: 1
    t.integer "user_id"
    t.boolean "is_visible", default: true, null: false
    t.integer "parent_id"
    t.integer "lft", default: 0
    t.integer "rgt", default: 0
    t.integer "depth", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lft", "rgt"], name: "index_structures_on_lft_and_rgt"
    t.index ["parent_id"], name: "index_structures_on_parent_id"
    t.index ["position_type_id"], name: "index_structures_on_position_type_id"
    t.index ["slug", "structure_type_id"], name: "index_structures_on_slug_and_structure_type_id", unique: true
  end

  create_table "tracks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.integer "trackable_id"
    t.string "trackable_type"
    t.integer "user_id"
    t.integer "owner_id"
    t.text "trackable_changes", limit: 16777215
    t.text "parameters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_tracks_on_key"
    t.index ["owner_id"], name: "index_tracks_on_owner_id"
    t.index ["trackable_type", "trackable_id"], name: "index_tracks_on_trackable_type_and_trackable_id"
    t.index ["user_id"], name: "index_tracks_on_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "login"
    t.integer "user_role_id", limit: 1, default: 1
    t.integer "gender", limit: 1, default: 1
    t.string "first_name"
    t.string "last_name"
    t.string "patronymic"
    t.string "phone"
    t.string "skype"
    t.string "web_site"
    t.string "address"
    t.date "birthday"
    t.string "time_zone"
    t.string "locale", limit: 10
    t.string "bg_color", default: "ffffff"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "password_salt"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
