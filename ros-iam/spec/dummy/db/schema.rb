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

ActiveRecord::Schema.define(version: 2019_02_15_214421) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.string "resource"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_actions_on_name", unique: true
  end

  create_table "credentials", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "access_key_id"
    t.string "secret_access_key_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["access_key_id"], name: "index_credentials_on_access_key_id", unique: true
    t.index ["owner_type", "owner_id"], name: "index_credentials_on_owner_type_and_owner_id"
  end

  create_table "group_policy_joins", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "policy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_group_policy_joins_on_group_id"
    t.index ["policy_id"], name: "index_group_policy_joins_on_policy_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "policies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_policies_on_name", unique: true
  end

  create_table "policy_actions", force: :cascade do |t|
    t.bigint "policy_id"
    t.bigint "action_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action_id"], name: "index_policy_actions_on_action_id"
    t.index ["policy_id", "action_id"], name: "index_policy_actions_on_policy_id_and_action_id", unique: true
    t.index ["policy_id"], name: "index_policy_actions_on_policy_id"
  end

  create_table "role_policy_joins", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "policy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["policy_id"], name: "index_role_policy_joins_on_policy_id"
    t.index ["role_id"], name: "index_role_policy_joins_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roots", force: :cascade do |t|
    t.boolean "api", default: false, null: false
    t.string "time_zone", default: "UTC", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_roots_on_email", unique: true
    t.index ["reset_password_token"], name: "index_roots_on_reset_password_token", unique: true
  end

  create_table "tenants", force: :cascade do |t|
    t.string "schema_name", null: false
    t.jsonb "properties"
    t.jsonb "platform_properties"
    t.bigint "root_id", null: false
    t.string "alias"
    t.string "name"
    t.string "state"
    t.index ["alias"], name: "index_tenants_on_alias", unique: true
    t.index ["root_id"], name: "index_tenants_on_root_id", unique: true
    t.index ["schema_name"], name: "index_tenants_on_schema_name", unique: true
  end

  create_table "user_credentials", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "credential_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credential_id"], name: "index_user_credentials_on_credential_id", unique: true
    t.index ["user_id"], name: "index_user_credentials_on_user_id"
  end

  create_table "user_groups", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "user_policy_joins", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "policy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["policy_id"], name: "index_user_policy_joins_on_policy_id"
    t.index ["user_id"], name: "index_user_policy_joins_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "console", default: false, null: false
    t.boolean "api", default: false, null: false
    t.string "time_zone", default: "UTC", null: false
    t.jsonb "attached_policies", default: {}, null: false
    t.jsonb "attached_actions", default: {}, null: false
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "group_policy_joins", "groups"
  add_foreign_key "group_policy_joins", "policies"
  add_foreign_key "policy_actions", "actions"
  add_foreign_key "policy_actions", "policies"
  add_foreign_key "role_policy_joins", "policies"
  add_foreign_key "role_policy_joins", "roles"
  add_foreign_key "tenants", "roots"
  add_foreign_key "user_credentials", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
  add_foreign_key "user_policy_joins", "policies"
  add_foreign_key "user_policy_joins", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
