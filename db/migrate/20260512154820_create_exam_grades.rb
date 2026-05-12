class CreateExamGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :exam_grades do |t|
      t.string :name
      t.integer :percentage_from
      t.integer :percentage_to
      t.text :description

      t.timestamps
    end
  end
end
