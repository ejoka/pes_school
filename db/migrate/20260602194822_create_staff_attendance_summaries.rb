class CreateStaffAttendanceSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_attendance_summaries do |t|
      t.references :staff_assignment, null: false, foreign_key: true
      t.integer :month
      t.integer :year
      t.integer :total_present
      t.integer :total_absent
      t.integer :total_late
      t.integer :total_leave
      t.decimal :attendance_percentage

      t.timestamps
    end
  end
end
