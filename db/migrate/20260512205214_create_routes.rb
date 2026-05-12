class CreateRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :routes do |t|
      t.string :name
      t.decimal :fare
      t.text :description

      t.timestamps
    end
  end
end
