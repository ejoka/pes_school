class CreateStockReceiptItems < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_receipt_items do |t|
      t.references :stock_receipt, null: false, foreign_key: true
      t.references :inventory_item, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :unit_price
      t.decimal :total_price

      t.timestamps
    end
  end
end
