class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name
      t.string :code
      t.text :description
      t.integer :hod_id

      t.timestamps
    end
  end
end
