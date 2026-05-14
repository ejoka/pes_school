class CreateWeeklyAttendanceSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_attendance_summaries do |t|
      t.references :student, null: false, foreign_key: true
      t.date :week_starting
      t.integer :total_present
      t.integer :total_absent
      t.integer :total_late
      t.decimal :attendance_percentage

      t.timestamps
    end
  end
end
