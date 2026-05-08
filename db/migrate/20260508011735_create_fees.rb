class CreateFees < ActiveRecord::Migration[8.0]
  def change
    create_table :fees do |t|
      t.references :student, null: false, foreign_key: true
      t.references :fee_type, null: false, foreign_key: true
      t.decimal :amount_to_pay
      t.decimal :amount_paid
      t.decimal :remaining_balance
      t.string :status
      t.date :due_date
      t.date :payment_date
      t.text :notes

      t.timestamps
    end
  end
end
