class CreateStaffLeaveRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_leave_requests do |t|
      t.references :staff_assignment, null: false, foreign_key: true
      t.string :leave_type
      t.date :start_date
      t.date :end_date
      t.text :reason
      t.string :status
      t.integer :user_id
      t.date :approved_date

      t.timestamps
    end
  end
end
