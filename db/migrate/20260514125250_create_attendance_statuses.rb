class CreateAttendanceStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :attendance_statuses do |t|
      t.string :name
      t.string :code
      t.string :color

      t.timestamps
    end
  end
end
