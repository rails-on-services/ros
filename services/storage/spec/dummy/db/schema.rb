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

ActiveRecord::Schema.define(version: 2019_09_18_173558) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "column_maps", force: :cascade do |t|
    t.bigint "transfer_map_id", null: false
    t.string "name", null: false
    t.string "user_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "transfer_map_id"], name: "index_column_maps_on_name_and_transfer_map_id"
    t.index ["transfer_map_id"], name: "index_column_maps_on_transfer_map_id"
  end

  create_table "platform_events", force: :cascade do |t|
    t.string "resource"
    t.string "event"
    t.string "destination"
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

  create_table "transfer_maps", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "service", null: false
    t.string "target", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

# Could not dump table "uploads" because of following StandardError
#   Unknown type 'uploads_state' for column 'workflow_state'

  add_foreign_key "column_maps", "transfer_maps", on_delete: :cascade
end
