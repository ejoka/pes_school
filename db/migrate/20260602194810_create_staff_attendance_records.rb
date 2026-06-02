# db/migrate/xxxx_create_staff_attendance_records.rb
class CreateStaffAttendanceRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :staff_attendance_records do |t|
      t.references :staff_assignment, null: false, foreign_key: true
      t.date :date, null: false
      t.references :staff_attendance_status, foreign_key: true  # Changed from status to staff_attendance_status
      t.time :check_in_time
      t.time :check_out_time
      t.text :notes
      t.references :recorded_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    
    add_index :staff_attendance_records, [:staff_assignment_id, :date], unique: true, name: 'index_staff_attendance_on_staff_and_date'
  end
end