class CreateStaffAttendanceManagements < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_attendance_managements do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
