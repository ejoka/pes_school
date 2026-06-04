class CreateGoalProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :goal_progresses do |t|
      t.references :goal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :comment
      t.integer :progress_percentage
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
