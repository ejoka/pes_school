class CreateAttendanceRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :attendance_records do |t|
      t.references :student, null: false, foreign_key: true
      t.references :school_class, null: false, foreign_key: true
      t.date :date
      t.references :attendance_status, null: false, foreign_key: true
      t.text :remarks
      t.integer :user_id

      t.timestamps
    end
  end
end
