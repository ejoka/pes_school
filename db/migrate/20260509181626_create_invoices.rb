class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :student, null: false, foreign_key: true
      t.string :invoice_number
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.decimal :paid_amount, precision: 10, scale: 2, default: 0
      t.string :status
      t.date :due_date
      t.date :generated_date
      t.text :pdf_data
      t.integer :created_by_id

      t.timestamps
    end
  end
end
