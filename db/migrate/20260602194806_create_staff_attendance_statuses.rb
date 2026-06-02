class CreateStaffAttendanceStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_attendance_statuses do |t|
      t.string :name
      t.string :code
      t.string :color

      t.timestamps
    end
  end
end
