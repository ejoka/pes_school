class CreateExamAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :exam_attendances do |t|
      t.references :student, null: false, foreign_key: true
      t.references :school_class, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :exam_schedule, null: false, foreign_key: true
      t.string :status
      t.text :remarks

      t.timestamps
    end
  end
end
