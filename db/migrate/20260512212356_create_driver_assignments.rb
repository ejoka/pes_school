class CreateDriverAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :driver_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :school_bus, null: false, foreign_key: true
      t.string :id_type
      t.string :id_number
      t.text :description
      t.date :assigned_date
      t.string :status

      t.timestamps
    end
  end
end
