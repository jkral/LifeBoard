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

ActiveRecord::Schema[8.0].define(version: 2025_05_26_185746) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.text "name"
    t.text "description"
    t.decimal "score", precision: 5, scale: 2, default: "10.0"
    t.bigint "position"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["name"], name: "idx_16548_index_categories_on_name", unique: true
    t.index ["position"], name: "idx_16548_index_categories_on_position", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id"
    t.text "ip_address"
    t.text "user_agent"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["user_id"], name: "idx_16541_index_sessions_on_user_id"
  end

  create_table "subcategories", force: :cascade do |t|
    t.bigint "category_id"
    t.text "name"
    t.text "description"
    t.decimal "score", precision: 5, scale: 2, default: "10.0"
    t.bigint "position"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.boolean "active", default: true
    t.index ["category_id", "name"], name: "idx_16556_index_subcategories_on_category_id_and_name", unique: true
    t.index ["category_id", "position"], name: "idx_16556_index_subcategories_on_category_id_and_position", unique: true
    t.index ["category_id"], name: "idx_16556_index_subcategories_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "email_address"
    t.text "password_digest"
    t.timestamptz "created_at"
    t.timestamptz "updated_at"
    t.index ["email_address"], name: "idx_16534_index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users", name: "sessions_user_id_fkey"
  add_foreign_key "subcategories", "categories", name: "subcategories_category_id_fkey"
end
