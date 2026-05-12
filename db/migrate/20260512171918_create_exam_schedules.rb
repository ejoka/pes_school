class CreateExamSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :exam_schedules do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :school_class, null: false, foreign_key: true
      t.references :exam_type, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :venue
      t.text :description

      t.timestamps
    end
  end
end
