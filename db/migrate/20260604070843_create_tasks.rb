class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :goal, null: false, foreign_key: true
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :status, default: 'pending'
      t.date :due_date
      t.datetime :completed_at
      t.string :priority, default: 'medium'
      t.timestamps
    end
    
    add_index :tasks, :user_id
    add_foreign_key :tasks, :users, column: :user_id
  end
end