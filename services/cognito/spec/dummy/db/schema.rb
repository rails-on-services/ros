# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_06_023315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chown_requests", force: :cascade do |t|
    t.bigint "to_id"
    t.jsonb "from_ids", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "chown_results", force: :cascade do |t|
    t.bigint "chown_request_id"
    t.string "service_name"
    t.bigint "from_id"
    t.bigint "to_id"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chown_request_id"], name: "index_chown_results_on_chown_request_id"
  end

  create_table "endpoints", force: :cascade do |t|
    t.string "url", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["target_type", "target_id"], name: "index_endpoints_on_target_type_and_target_id"
    t.index ["url"], name: "index_endpoints_on_url", unique: true
  end

  create_table "identifiers", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.bigint "user_id"
    t.jsonb "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_identifiers_on_user_id"
  end

  create_table "platform_events", force: :cascade do |t|
    t.string "resource"
    t.string "event"
    t.string "destination"
  end

  create_table "pools", force: :cascade do |t|
    t.string "name"
    t.jsonb "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_pools_on_name", unique: true
  end

  create_table "tenant_events", force: :cascade do |t|
    t.string "resource"
    t.string "event"
    t.string "destination"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "schema_name", null: false
    t.jsonb "properties", default: {}, null: false
    t.jsonb "platform_properties", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["schema_name"], name: "index_tenants_on_schema_name", unique: true
  end

  create_table "user_pools", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "pool_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pool_id"], name: "index_user_pools_on_pool_id"
    t.index ["user_id"], name: "index_user_pools_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "primary_identifier"
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "email_address"
    t.boolean "anonymous", default: false
    t.jsonb "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["primary_identifier"], name: "index_users_on_primary_identifier", unique: true
  end

  add_foreign_key "identifiers", "users"
  add_foreign_key "user_pools", "pools"
  add_foreign_key "user_pools", "users"
end
