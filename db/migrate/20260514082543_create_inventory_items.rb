class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items do |t|
      t.string :name
      t.references :inventory_category, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.integer :quantity
      t.integer :minimum_stock
      t.string :unit
      t.decimal :unit_price
      t.string :location
      t.text :description

      t.timestamps
    end
  end
end
