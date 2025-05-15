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

ActiveRecord::Schema[8.0].define(version: 2025_05_14_102731) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attribute_definitions", force: :cascade do |t|
    t.bigint "insurance_type_id", null: false
    t.string "name"
    t.string "data_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insurance_type_id"], name: "index_attribute_definitions_on_insurance_type_id"
    t.index ["name"], name: "index_attribute_definitions_on_name"
  end

  create_table "attribute_metadata", force: :cascade do |t|
    t.bigint "attribute_definition_id", null: false
    t.string "label"
    t.boolean "is_dropdown"
    t.jsonb "dropdown_options"
    t.decimal "min_value"
    t.decimal "max_value"
    t.string "validation_regex"
    t.text "help_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_definition_id"], name: "index_attribute_metadata_on_attribute_definition_id"
    t.index ["dropdown_options"], name: "index_attribute_metadata_on_dropdown_options", using: :gin
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "category_group_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_group_id"], name: "index_categories_on_category_group_id"
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "category_attributes", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "attribute_definition_id", null: false
    t.boolean "is_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_definition_id"], name: "index_category_attributes_on_attribute_definition_id"
    t.index ["category_id"], name: "index_category_attributes_on_category_id"
  end

  create_table "category_groups", force: :cascade do |t|
    t.bigint "insurance_type_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insurance_type_id"], name: "index_category_groups_on_insurance_type_id"
    t.index ["name"], name: "index_category_groups_on_name"
  end

  create_table "claims", force: :cascade do |t|
    t.bigint "policy_id", null: false
    t.string "claim_number"
    t.text "description"
    t.decimal "claimed_amount"
    t.date "incident_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_number"], name: "index_claims_on_claim_number", unique: true
    t.index ["incident_date"], name: "index_claims_on_incident_date"
    t.index ["policy_id"], name: "index_claims_on_policy_id"
    t.index ["status"], name: "index_claims_on_status"
  end

  create_table "coverage_types", force: :cascade do |t|
    t.bigint "insurance_type_id", null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insurance_type_id"], name: "index_coverage_types_on_insurance_type_id"
    t.index ["name"], name: "index_coverage_types_on_name"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "birthdate"
    t.string "gender"
    t.string "region"
    t.string "subcity"
    t.string "woreda"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "entity_attributes", force: :cascade do |t|
    t.bigint "entity_type_id", null: false
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.bigint "attribute_definition_id", null: false
    t.jsonb "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attribute_definition_id"], name: "index_entity_attributes_on_attribute_definition_id"
    t.index ["entity_type", "entity_id"], name: "index_entity_attributes_on_entity"
    t.index ["entity_type_id"], name: "index_entity_attributes_on_entity_type_id"
  end

  create_table "entity_categories", force: :cascade do |t|
    t.bigint "entity_type_id", null: false
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_entity_categories_on_category_id"
    t.index ["entity_type", "entity_id"], name: "index_entity_categories_on_entity"
    t.index ["entity_type_id"], name: "index_entity_categories_on_entity_type_id"
  end

  create_table "entity_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_entity_types_on_name", unique: true
  end

  create_table "insurance_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_insurance_types_on_name", unique: true
  end

  create_table "insured_entities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "insurance_type_id", null: false
    t.string "entity_type", null: false
    t.bigint "entity_id", null: false
    t.bigint "entity_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id"], name: "index_insured_entities_on_entity"
    t.index ["entity_type_id"], name: "index_insured_entities_on_entity_type_id"
    t.index ["insurance_type_id"], name: "index_insured_entities_on_insurance_type_id"
    t.index ["user_id"], name: "index_insured_entities_on_user_id"
  end

  create_table "liability_limits", force: :cascade do |t|
    t.bigint "insurance_type_id", null: false
    t.bigint "coverage_type_id", null: false
    t.string "benefit_type"
    t.decimal "min_limit"
    t.decimal "max_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coverage_type_id"], name: "index_liability_limits_on_coverage_type_id"
    t.index ["insurance_type_id"], name: "index_liability_limits_on_insurance_type_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name", null: false
    t.string "resource", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource", "action"], name: "index_permissions_on_name_and_resource_and_action", unique: true
  end

  create_table "policies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "insured_entity_id", null: false
    t.bigint "coverage_type_id", null: false
    t.string "policy_number"
    t.date "start_date"
    t.date "end_date"
    t.decimal "premium_amount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coverage_type_id"], name: "index_policies_on_coverage_type_id"
    t.index ["end_date"], name: "index_policies_on_end_date"
    t.index ["insured_entity_id"], name: "index_policies_on_insured_entity_id"
    t.index ["policy_number"], name: "index_policies_on_policy_number", unique: true
    t.index ["start_date"], name: "index_policies_on_start_date"
    t.index ["status"], name: "index_policies_on_status"
    t.index ["user_id"], name: "index_policies_on_user_id"
  end

  create_table "premium_rates", force: :cascade do |t|
    t.bigint "insurance_type_id", null: false
    t.jsonb "criteria"
    t.string "rate_type"
    t.decimal "rate"
    t.date "effective_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["criteria"], name: "index_premium_rates_on_criteria", using: :gin
    t.index ["effective_date"], name: "index_premium_rates_on_effective_date"
    t.index ["insurance_type_id"], name: "index_premium_rates_on_insurance_type_id"
    t.index ["rate_type"], name: "index_premium_rates_on_rate_type"
    t.index ["status"], name: "index_premium_rates_on_status"
  end

  create_table "quotation_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "insurance_type_id", null: false
    t.bigint "coverage_type_id", null: false
    t.bigint "vehicle_id", null: false
    t.string "status", default: "draft", null: false
    t.jsonb "form_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coverage_type_id"], name: "index_quotation_requests_on_coverage_type_id"
    t.index ["insurance_type_id"], name: "index_quotation_requests_on_insurance_type_id"
    t.index ["user_id"], name: "index_quotation_requests_on_user_id"
    t.index ["vehicle_id"], name: "index_quotation_requests_on_vehicle_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "refresh_token", null: false
    t.datetime "expires_at", null: false
    t.string "device", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["refresh_token"], name: "index_refresh_tokens_on_refresh_token", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "phone_number"
    t.string "fin"
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["fin"], name: "index_users_on_fin", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "plate_number"
    t.string "chassis_number"
    t.string "engine_number"
    t.integer "year_of_manufacture"
    t.string "make"
    t.string "model"
    t.decimal "estimated_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chassis_number"], name: "index_vehicles_on_chassis_number", unique: true
    t.index ["engine_number"], name: "index_vehicles_on_engine_number", unique: true
    t.index ["plate_number"], name: "index_vehicles_on_plate_number", unique: true
  end

  create_table "verification_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.integer "token_type", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_verification_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_verification_tokens_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attribute_definitions", "insurance_types"
  add_foreign_key "attribute_metadata", "attribute_definitions"
  add_foreign_key "categories", "category_groups"
  add_foreign_key "category_attributes", "attribute_definitions"
  add_foreign_key "category_attributes", "categories"
  add_foreign_key "category_groups", "insurance_types"
  add_foreign_key "claims", "policies"
  add_foreign_key "coverage_types", "insurance_types"
  add_foreign_key "customers", "users"
  add_foreign_key "entity_attributes", "attribute_definitions"
  add_foreign_key "entity_attributes", "entity_types"
  add_foreign_key "entity_categories", "categories"
  add_foreign_key "entity_categories", "entity_types"
  add_foreign_key "insured_entities", "entity_types"
  add_foreign_key "insured_entities", "insurance_types"
  add_foreign_key "insured_entities", "users"
  add_foreign_key "liability_limits", "coverage_types"
  add_foreign_key "liability_limits", "insurance_types"
  add_foreign_key "policies", "coverage_types"
  add_foreign_key "policies", "insured_entities"
  add_foreign_key "policies", "users"
  add_foreign_key "premium_rates", "insurance_types"
  add_foreign_key "quotation_requests", "coverage_types"
  add_foreign_key "quotation_requests", "insurance_types"
  add_foreign_key "quotation_requests", "users"
  add_foreign_key "quotation_requests", "vehicles"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "verification_tokens", "users"
end
