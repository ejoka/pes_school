class CreateStockReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_receipts do |t|
      t.string :receipt_number
      t.references :supplier, null: false, foreign_key: true
      t.date :received_date
      t.string :status
      t.text :notes
      t.integer :user_id

      t.timestamps
    end
  end
end
