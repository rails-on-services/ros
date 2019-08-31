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

ActiveRecord::Schema.define(version: 2019_08_28_151554) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orgs", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.jsonb "properties"
    t.jsonb "display_properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

end
