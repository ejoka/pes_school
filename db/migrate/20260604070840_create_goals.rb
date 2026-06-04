class CreateGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :goals do |t|
      t.string :title
      t.string :description
      t.string :professional_type
      t.string :status
      t.date :start_date
      t.date :end_date
      t.string :priority
      t.integer :progress
      t.integer :user_id

      t.timestamps
    end
  end
end
