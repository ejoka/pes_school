class CreateStaffAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.string :position
      t.date :joined_date
      t.string :status

      t.timestamps
    end
  end
end
