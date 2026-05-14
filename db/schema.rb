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

ActiveRecord::Schema[8.0].define(version: 2026_05_14_125255) do
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

  create_table "attendance_records", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "school_class_id", null: false
    t.date "date"
    t.bigint "attendance_status_id", null: false
    t.text "remarks"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_status_id"], name: "index_attendance_records_on_attendance_status_id"
    t.index ["school_class_id"], name: "index_attendance_records_on_school_class_id"
    t.index ["student_id"], name: "index_attendance_records_on_student_id"
  end

  create_table "attendance_statuses", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bus_route_assignments", force: :cascade do |t|
    t.bigint "school_bus_id", null: false
    t.bigint "route_id", null: false
    t.text "description"
    t.date "assigned_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_bus_route_assignments_on_route_id"
    t.index ["school_bus_id"], name: "index_bus_route_assignments_on_school_bus_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "driver_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "school_bus_id", null: false
    t.string "id_type"
    t.string "id_number"
    t.text "description"
    t.date "assigned_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_bus_id"], name: "index_driver_assignments_on_school_bus_id"
    t.index ["user_id"], name: "index_driver_assignments_on_user_id"
  end

  create_table "enter_marks", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "school_class_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "exam_attendance_id", null: false
    t.decimal "marks_obtained"
    t.decimal "total_marks"
    t.decimal "percentage"
    t.string "grade"
    t.text "remarks"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_attendance_id"], name: "index_enter_marks_on_exam_attendance_id"
    t.index ["school_class_id"], name: "index_enter_marks_on_school_class_id"
    t.index ["student_id"], name: "index_enter_marks_on_student_id"
    t.index ["subject_id"], name: "index_enter_marks_on_subject_id"
  end

  create_table "exam_attendances", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "school_class_id", null: false
    t.bigint "subject_id", null: false
    t.bigint "exam_schedule_id", null: false
    t.string "status"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_schedule_id"], name: "index_exam_attendances_on_exam_schedule_id"
    t.index ["school_class_id"], name: "index_exam_attendances_on_school_class_id"
    t.index ["student_id"], name: "index_exam_attendances_on_student_id"
    t.index ["subject_id"], name: "index_exam_attendances_on_subject_id"
  end

  create_table "exam_grades", force: :cascade do |t|
    t.string "name"
    t.integer "percentage_from"
    t.integer "percentage_to"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exam_managements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exam_schedules", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "school_class_id", null: false
    t.bigint "exam_type_id", null: false
    t.bigint "user_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "venue"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_type_id"], name: "index_exam_schedules_on_exam_type_id"
    t.index ["school_class_id"], name: "index_exam_schedules_on_school_class_id"
    t.index ["subject_id"], name: "index_exam_schedules_on_subject_id"
    t.index ["user_id"], name: "index_exam_schedules_on_user_id"
  end

  create_table "exam_types", force: :cascade do |t|
    t.string "name"
    t.decimal "average_pass_mark"
    t.text "description"
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

  create_table "inventory_categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventory_items", force: :cascade do |t|
    t.string "name"
    t.bigint "inventory_category_id", null: false
    t.bigint "supplier_id", null: false
    t.integer "quantity"
    t.integer "minimum_stock"
    t.string "unit"
    t.decimal "unit_price"
    t.string "location"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_category_id"], name: "index_inventory_items_on_inventory_category_id"
    t.index ["supplier_id"], name: "index_inventory_items_on_supplier_id"
  end

  create_table "inventory_managements", force: :cascade do |t|
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

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.decimal "fare"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_buses", force: :cascade do |t|
    t.string "bus_number"
    t.string "bus_model"
    t.integer "capacity"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "stock_movements", force: :cascade do |t|
    t.bigint "inventory_item_id", null: false
    t.string "movement_type"
    t.integer "quantity"
    t.string "reference_number"
    t.date "date"
    t.text "notes"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_stock_movements_on_inventory_item_id"
  end

  create_table "stock_receipt_items", force: :cascade do |t|
    t.bigint "stock_receipt_id", null: false
    t.bigint "inventory_item_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_stock_receipt_items_on_inventory_item_id"
    t.index ["stock_receipt_id"], name: "index_stock_receipt_items_on_stock_receipt_id"
  end

  create_table "stock_receipts", force: :cascade do |t|
    t.string "receipt_number"
    t.bigint "supplier_id", null: false
    t.date "received_date"
    t.string "status"
    t.text "notes"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_stock_receipts_on_supplier_id"
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

  create_table "student_transport_assignments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "route_id", null: false
    t.date "assigned_date"
    t.string "status"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_student_transport_assignments_on_route_id"
    t.index ["student_id"], name: "index_student_transport_assignments_on_student_id"
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

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.string "contact_person"
    t.string "phone"
    t.string "email"
    t.text "address"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transport_managements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "weekly_attendance_summaries", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.date "week_starting"
    t.integer "total_present"
    t.integer "total_absent"
    t.integer "total_late"
    t.decimal "attendance_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_weekly_attendance_summaries_on_student_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendance_records", "attendance_statuses"
  add_foreign_key "attendance_records", "school_classes"
  add_foreign_key "attendance_records", "students"
  add_foreign_key "bus_route_assignments", "routes"
  add_foreign_key "bus_route_assignments", "school_buses"
  add_foreign_key "driver_assignments", "school_buses"
  add_foreign_key "driver_assignments", "users"
  add_foreign_key "enter_marks", "exam_attendances"
  add_foreign_key "enter_marks", "school_classes"
  add_foreign_key "enter_marks", "students"
  add_foreign_key "enter_marks", "subjects"
  add_foreign_key "exam_attendances", "exam_schedules"
  add_foreign_key "exam_attendances", "school_classes"
  add_foreign_key "exam_attendances", "students"
  add_foreign_key "exam_attendances", "subjects"
  add_foreign_key "exam_schedules", "exam_types"
  add_foreign_key "exam_schedules", "school_classes"
  add_foreign_key "exam_schedules", "subjects"
  add_foreign_key "exam_schedules", "users"
  add_foreign_key "inventory_items", "inventory_categories"
  add_foreign_key "inventory_items", "suppliers"
  add_foreign_key "invoices", "students"
  add_foreign_key "parent_infos", "students"
  add_foreign_key "payments", "students"
  add_foreign_key "school_classes", "categories"
  add_foreign_key "stock_movements", "inventory_items"
  add_foreign_key "stock_receipt_items", "inventory_items"
  add_foreign_key "stock_receipt_items", "stock_receipts"
  add_foreign_key "stock_receipts", "suppliers"
  add_foreign_key "student_fees", "fee_categories"
  add_foreign_key "student_fees", "students"
  add_foreign_key "student_transport_assignments", "routes"
  add_foreign_key "student_transport_assignments", "students"
  add_foreign_key "students", "school_classes"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "school_classes"
  add_foreign_key "user_resources", "users"
  add_foreign_key "weekly_attendance_summaries", "students"
end
