class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :inventory_item, null: false, foreign_key: true
      t.string :movement_type
      t.integer :quantity
      t.string :reference_number
      t.date :date
      t.text :notes
      t.integer :user_id

      t.timestamps
    end
  end
end
