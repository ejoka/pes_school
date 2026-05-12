class CreateExamManagements < ActiveRecord::Migration[8.0]
  def change
    create_table :exam_managements do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
