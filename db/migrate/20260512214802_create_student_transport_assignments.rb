class CreateStudentTransportAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :student_transport_assignments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.date :assigned_date
      t.string :status
      t.text :description

      t.timestamps
    end
  end
end
