class CreateEnterMarks < ActiveRecord::Migration[8.0]
  def change
    create_table :enter_marks do |t|
      t.references :student, null: false, foreign_key: true
      t.references :school_class, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :exam_attendance, null: false, foreign_key: true
      t.decimal :marks_obtained
      t.decimal :total_marks
      t.decimal :percentage
      t.string :grade
      t.text :remarks
      t.integer :user_id

      t.timestamps
    end
  end
end
