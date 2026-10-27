# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_27_200001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.integer "kind", null: false
    t.string "label", null: false
    t.string "street", null: false
    t.string "postcode", null: false
    t.string "city", null: false
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_addresses_on_company_id"
    t.index ["latitude", "longitude"], name: "index_addresses_on_latitude_and_longitude"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "siret"
    t.text "description"
    t.boolean "can_buy", default: true, null: false
    t.boolean "can_sell", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "legal_form"
    t.string "naf_code"
    t.string "vat_number"
    t.boolean "vat_exempt", default: false, null: false
    t.string "administrative_status"
    t.datetime "siret_verified_at"
    t.text "certifications"
    t.text "production_method"
    t.index ["siret"], name: "index_companies_on_siret", unique: true, where: "(siret IS NOT NULL)"
  end

  create_table "discount_tiers", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.integer "min_quantity", null: false
    t.decimal "discount_percent", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "min_quantity"], name: "index_discount_tiers_on_listing_id_and_min_quantity", unique: true
    t.index ["listing_id"], name: "index_discount_tiers_on_listing_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "favorite_company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "favorite_company_id"], name: "index_favorites_on_company_id_and_favorite_company_id", unique: true
    t.index ["company_id"], name: "index_favorites_on_company_id"
    t.index ["favorite_company_id"], name: "index_favorites_on_favorite_company_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "product_id", null: false
    t.bigint "address_id", null: false
    t.integer "kind", null: false
    t.integer "status", default: 0, null: false
    t.string "label"
    t.string "size"
    t.integer "quantity", null: false
    t.string "unit", null: false
    t.integer "unit_price_cents"
    t.integer "max_price_cents"
    t.date "needed_on"
    t.date "available_until"
    t.integer "radius_km", default: 30, null: false
    t.integer "min_order_cents"
    t.string "pickup_hours"
    t.text "delivery_terms"
    t.string "priorities", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nature", default: 0, null: false
    t.integer "storage"
    t.text "free_text"
    t.uuid "group_id"
    t.index ["address_id"], name: "index_listings_on_address_id"
    t.index ["company_id"], name: "index_listings_on_company_id"
    t.index ["group_id"], name: "index_listings_on_group_id"
    t.index ["kind", "status", "product_id"], name: "index_listings_on_kind_and_status_and_product_id"
    t.index ["product_id"], name: "index_listings_on_product_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.integer "kind", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "buyer_company_id", null: false
    t.bigint "seller_company_id", null: false
    t.bigint "need_id", null: false
    t.bigint "offer_id", null: false
    t.bigint "product_id", null: false
    t.bigint "address_id", null: false
    t.string "label"
    t.string "size"
    t.string "unit", null: false
    t.integer "quantity", null: false
    t.integer "unit_price_cents", null: false
    t.integer "total_cents", null: false
    t.decimal "discount_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.date "needed_on", null: false
    t.integer "fulfillment", default: 0, null: false
    t.string "pickup_hours"
    t.string "payment_terms", default: "À la remise", null: false
    t.string "reference", null: false
    t.integer "status", default: 0, null: false
    t.datetime "accepted_at"
    t.datetime "declined_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lot_number"
    t.date "best_before"
    t.datetime "delivered_at"
    t.index ["address_id"], name: "index_orders_on_address_id"
    t.index ["buyer_company_id", "status"], name: "index_orders_on_buyer_company_id_and_status"
    t.index ["buyer_company_id"], name: "index_orders_on_buyer_company_id"
    t.index ["need_id"], name: "index_orders_on_need_id"
    t.index ["offer_id"], name: "index_orders_on_offer_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["reference"], name: "index_orders_on_reference", unique: true
    t.index ["seller_company_id", "status"], name: "index_orders_on_seller_company_id_and_status"
    t.index ["seller_company_id"], name: "index_orders_on_seller_company_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.string "default_unit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "processed", default: false, null: false
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "addresses", "companies"
  add_foreign_key "discount_tiers", "listings"
  add_foreign_key "favorites", "companies"
  add_foreign_key "favorites", "companies", column: "favorite_company_id"
  add_foreign_key "listings", "addresses"
  add_foreign_key "listings", "companies"
  add_foreign_key "listings", "products"
  add_foreign_key "notifications", "users"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "companies", column: "buyer_company_id"
  add_foreign_key "orders", "companies", column: "seller_company_id"
  add_foreign_key "orders", "listings", column: "need_id"
  add_foreign_key "orders", "listings", column: "offer_id"
  add_foreign_key "orders", "products"
  add_foreign_key "users", "companies"
end
