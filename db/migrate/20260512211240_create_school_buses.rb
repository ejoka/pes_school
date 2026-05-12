class CreateSchoolBuses < ActiveRecord::Migration[8.0]
  def change
    create_table :school_buses do |t|
      t.string :bus_number
      t.string :bus_model
      t.integer :capacity
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
