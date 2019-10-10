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

ActiveRecord::Schema.define(version: 2019_03_17_114527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "owner_type"
    t.bigint "owner_id"
    t.integer "cognito_endpoint_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_campaigns_on_owner_type_and_owner_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.bigint "campaign_entity_id"
    t.bigint "template_id"
    t.string "target_type"
    t.bigint "target_id"
    t.bigint "provider_id"
    t.string "status", null: false
    t.string "channel"
    t.datetime "send_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_entity_id"], name: "index_events_on_campaign_entity_id"
    t.index ["provider_id"], name: "index_events_on_provider_id"
    t.index ["target_type", "target_id"], name: "index_events_on_target_type_and_target_id"
    t.index ["template_id"], name: "index_events_on_template_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "provider_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "channel"
    t.string "from"
    t.string "to"
    t.string "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_type", "owner_id"], name: "index_messages_on_owner_type_and_owner_id"
    t.index ["provider_id"], name: "index_messages_on_provider_id"
  end

  create_table "platform_events", force: :cascade do |t|
    t.string "resource"
    t.string "event"
    t.string "destination"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.string "encrypted_credentials"
    t.string "encrypted_credentials_iv"
    t.string "encrypted_credential_1"
    t.string "encrypted_credential_1_iv"
    t.string "encrypted_credential_2"
    t.string "encrypted_credential_2_iv"
    t.string "encrypted_credential_3"
    t.string "encrypted_credential_3_iv"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "campaign_entity_id"
    t.text "content"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_entity_id"], name: "index_templates_on_campaign_entity_id"
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

  create_table "whatsapps", force: :cascade do |t|
    t.string "sms_message_sid"
    t.string "num_media"
    t.string "sms_sid"
    t.string "sms_status"
    t.string "body"
    t.string "to"
    t.string "num_segments"
    t.string "message_sid"
    t.string "account_sid"
    t.string "from"
    t.string "api_version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "events", "campaigns", column: "campaign_entity_id"
  add_foreign_key "events", "providers"
  add_foreign_key "events", "templates"
  add_foreign_key "messages", "providers"
  add_foreign_key "templates", "campaigns", column: "campaign_entity_id"
end
