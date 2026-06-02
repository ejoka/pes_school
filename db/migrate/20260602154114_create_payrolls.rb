class CreatePayrolls < ActiveRecord::Migration[8.0]
  def change
    create_table :payrolls do |t|
      t.references :staff_assignment, null: false, foreign_key: true
      t.integer :month
      t.integer :year
      t.decimal :basic_salary
      t.decimal :allowances
      t.decimal :deductions
      t.decimal :net_salary
      t.date :payment_date
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
