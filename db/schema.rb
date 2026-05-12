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

ActiveRecord::Schema[8.0].define(version: 2026_05_11_125758) do
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

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fee_categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "is_recurring", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fee_managements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.string "invoice_number"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "paid_amount", precision: 10, scale: 2, default: "0.0"
    t.string "status"
    t.date "due_date"
    t.date "generated_date"
    t.text "pdf_data"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_invoices_on_student_id"
  end

  create_table "parent_infos", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.string "father_name"
    t.string "father_occupation"
    t.string "father_phone"
    t.string "father_email"
    t.string "mother_name"
    t.string "mother_occupation"
    t.string "mother_phone"
    t.string "mother_email"
    t.string "guardian_name"
    t.string "guardian_occupation"
    t.string "guardian_phone"
    t.string "guardian_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_parent_infos_on_student_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.decimal "amount"
    t.date "payment_date"
    t.string "payment_method"
    t.string "reference"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.string "payable_type"
    t.integer "payable_id"
    t.index ["student_id"], name: "index_payments_on_student_id"
  end

  create_table "school_classes", force: :cascade do |t|
    t.string "name"
    t.integer "pass_mark"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_school_classes_on_category_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_fees", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "fee_category_id", null: false
    t.decimal "amount"
    t.date "due_date"
    t.boolean "is_paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invoice_id"
    t.decimal "amount_paid", default: "0.0"
    t.index ["fee_category_id"], name: "index_student_fees_on_fee_category_id"
    t.index ["student_id"], name: "index_student_fees_on_student_id"
  end

  create_table "student_managements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "gender"
    t.string "religion"
    t.string "academic_year"
    t.date "admission_date"
    t.text "student_address"
    t.bigint "school_class_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_class_id"], name: "index_students_on_school_class_id"
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.string "subject_code"
    t.integer "pass_mark"
    t.bigint "school_class_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_class_id"], name: "index_subjects_on_school_class_id"
  end

  create_table "user_resources", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "permissions"
    t.index ["user_id"], name: "index_user_resources_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "title"
    t.string "phone_number"
    t.integer "role"
    t.string "professional_type"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "invoices", "students"
  add_foreign_key "parent_infos", "students"
  add_foreign_key "payments", "students"
  add_foreign_key "school_classes", "categories"
  add_foreign_key "student_fees", "fee_categories"
  add_foreign_key "student_fees", "students"
  add_foreign_key "students", "school_classes"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "school_classes"
  add_foreign_key "user_resources", "users"
end
