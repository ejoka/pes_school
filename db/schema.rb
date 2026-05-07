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

ActiveRecord::Schema[8.0].define(version: 2026_05_07_201944) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "school_classes", force: :cascade do |t|
    t.string "name"
    t.integer "pass_mark"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_school_classes_on_category_id"
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

  add_foreign_key "parent_infos", "students"
  add_foreign_key "school_classes", "categories"
  add_foreign_key "students", "school_classes"
  add_foreign_key "students", "users"
  add_foreign_key "subjects", "school_classes"
  add_foreign_key "user_resources", "users"
end
