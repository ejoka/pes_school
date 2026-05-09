class CreateStudentFees < ActiveRecord::Migration[8.0]
  def change
    create_table :student_fees do |t|
      t.references :student, null: false, foreign_key: true
      t.references :fee_category, null: false, foreign_key: true
      t.decimal :amount
      t.date :due_date
      t.boolean :is_paid, default: false

      t.timestamps
    end
  end
end
