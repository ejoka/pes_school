class CreateExamTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :exam_types do |t|
      t.string :name
      t.decimal :average_pass_mark
      t.text :description

      t.timestamps
    end
  end
end
