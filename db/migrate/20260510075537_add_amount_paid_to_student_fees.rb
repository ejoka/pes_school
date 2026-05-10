class AddAmountPaidToStudentFees < ActiveRecord::Migration[8.0]
  def change
    add_column :student_fees, :amount_paid, :decimal, default: 0
  end
end
