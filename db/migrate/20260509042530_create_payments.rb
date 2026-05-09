class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :student, null: false, foreign_key: true
      t.decimal :amount
      t.date :payment_date
      t.string :payment_method
      t.string :reference
      t.text :notes

      t.timestamps
    end
  end
end
