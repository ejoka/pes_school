class CreateBusRouteAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :bus_route_assignments do |t|
      t.references :school_bus, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.text :description
      t.date :assigned_date
      t.string :status

      t.timestamps
    end
  end
end
