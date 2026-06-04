class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :message
      t.boolean :read
      t.string :actionable_type
      t.integer :actionable_id

      t.timestamps
    end
  end
end
